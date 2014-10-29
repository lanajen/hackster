module GraphHelper

  private
    def complete_dates rows, start_date, end_date, start=0
      cumul = start
      (start_date..end_date).map do |date|
        new_value = rows[date.strftime('%Y-%m-%d')] || 0
        if start.zero?
          [date, new_value]
        else
          cumul += new_value
          [date, new_value, cumul]
        end
      end
    end

    def extract_date_and_int_from records_array, add_cumul=0
      rows = {}
      records_array.rows.map do |row|
        rows[row[0]] = row[1].to_i
      end
      complete_dates rows, Date.today-31, Date.today-1, add_cumul
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

    def graph_with_dates_for sql, title, chart_type, add_cumul=0
      records_array = ActiveRecord::Base.connection.exec_query(sql)
      rows = extract_date_and_int_from records_array, add_cumul
      columns = [['date', 'Day'], ['number', 'Total']]
      columns << ['number', 'Cumul'] unless add_cumul.zero?
      graph rows, columns, title, chart_type, !add_cumul.zero?
    end
end