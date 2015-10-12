class AddHidToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :hid, :string, length: 10
    add_column :projects, :hproperties, :hstore
    add_index :projects, :hid
  end
end
