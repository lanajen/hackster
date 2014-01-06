module GraphHelper
  def graph rows, columns, title, chart_type
    data_table = GoogleVisualr::DataTable.new

    columns.each do |column|
      data_table.new_column(column[0], column[1])
    end

    data_table.add_rows rows

    option = { width: 600, height: 350, title: title }
    "GoogleVisualr::Interactive::#{chart_type}".constantize.new(data_table, option)
  end
end