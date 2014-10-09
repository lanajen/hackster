class AddPropertiesToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :properties, :text
  end
end
