class AddDatesToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :start_date, :datetime
    add_column :groups, :end_date, :datetime
  end
end
