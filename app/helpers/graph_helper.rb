module GraphHelper
  def graph rows, columns, title, chart_type
    data_table = GoogleVisualr::DataTable.new

    columns.each do |column|
      data_table.new_column(column[0], column[1])
    end

    data_table.add_rows rows

    option = { width: '100%', height: 350, title: title }
    "GoogleVisualr::Interactive::#{chart_type}".constantize.new(data_table, option)
  end

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
end