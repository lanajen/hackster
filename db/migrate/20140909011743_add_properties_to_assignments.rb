class AddPropertiesToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :properties, :text
  end
end
