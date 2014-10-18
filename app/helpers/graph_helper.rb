module GraphHelper

  private
    def complete_dates rows, start_date, end_date
      (start_date..end_date).map do |date|
        [date, rows[date.strftime('%Y-%m-%d')] || 0]
      end
    end

    def extract_date_and_int_from records_array
      rows = {}
      records_array.rows.map do |row|
        rows[row[0]] = row[1].to_i
      end
      complete_dates rows, Date.today-30, Date.today
    end

    def graph rows, columns, title, chart_type
      data_table = GoogleVisualr::DataTable.new

      columns.each do |column|
        data_table.new_column(column[0], column[1])
      end

      data_table.add_rows rows

      option = { width: '100%', height: 350, title: title, hAxis: { textStyle: { color: '#666' }, gridlines: { color: '#eee' } }, color: '#08C', lineWidth: 2, areaOpacity: 0.2, pointSize: 4, chartArea: { backgroundColor: '#fdfdfd' }, legend: { position: 'none' } }
      "GoogleVisualr::Interactive::#{chart_type}".constantize.new(data_table, option)
    end

    def graph_with_dates_for sql, title, chart_type
      records_array = ActiveRecord::Base.connection.exec_query(sql)
      rows = extract_date_and_int_from records_array
      columns = [['date', 'Day'], ['number', 'Total']]
      graph rows, columns, title, chart_type
    end
end