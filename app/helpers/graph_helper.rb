module GraphHelper

  private
    def complete_dates rows, start_date, end_date, start=0, interval_type='day'
      cumul = start
      case interval_type
      when 'day'
        (start_date..end_date).map do |date|
          new_value = rows[date.strftime('%Y-%m-%d')] || 0
          if start.zero?
            [date.strftime('%B %Y, %d'), new_value]
          else
            cumul += new_value
            [date.strftime('%B %Y, %d'), new_value, cumul]
          end
        end
      when 'month'
        this_month = start_date
        out = []
        while (this_month <= end_date) do
          new_value = rows[this_month.strftime('%Y-%m')] || 0
          out << if start.zero?
            [this_month.strftime('%b %Y'), new_value]
          else
            cumul += new_value
            [this_month.strftime('%b %Y'), new_value, cumul]
          end
          this_month += 1.month
        end
        out
      end
    end

    def extract_date_and_int_from records_array, add_cumul=0, interval_type, start_date
      rows = {}
      records_array.rows.map do |row|
        rows[row[0]] = row[1].to_i
      end
      case interval_type
      when 'day'
        start_date ||= Date.today-31
        complete_dates rows, start_date, Date.today-1, add_cumul
      when 'month'
        start_date = start_date ? start_date.beginning_of_month : Date.today.months_since(-12)
        complete_dates rows, start_date, Date.today, add_cumul, interval_type
      else
        raise 'unknown interval: ' + interval_type.to_s
      end
    end

    def graph rows, columns, title, chart_type, with_cumul=false
      data_table = GoogleVisualr::DataTable.new

      columns.each do |column|
        data_table.new_column(column[0], column[1])
      end

      data_table.add_rows rows

      options = { width: '100%', height: 350, title: title, hAxis: { textStyle: { color: '#666' }, gridlines: { color: '#eee' } }, color: '#08C', lineWidth: 2, areaOpacity: 0.2, pointSize: 3, chartArea: { backgroundColor: '#fdfdfd' }, legend: { position: 'none' } }
      options[:series] = [{ targetAxisIndex: 1, type: 'bars' }, {}] if with_cumul
      "GoogleVisualr::Interactive::#{chart_type}".constantize.new(data_table, options)
    end

    def graph_with_dates_for sql, title, chart_type, add_cumul=0, interval_type='day', first_date=nil
      records_array = ActiveRecord::Base.connection.exec_query(sql)
      rows = extract_date_and_int_from records_array, add_cumul, interval_type, first_date
      columns = [['string', interval_type.capitalize], ['number', 'Total']]
      columns << ['number', 'Cumul'] unless add_cumul.zero?
      graph rows, columns, title, chart_type, !add_cumul.zero?
    end
end