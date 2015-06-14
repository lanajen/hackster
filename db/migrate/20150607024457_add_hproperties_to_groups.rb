class AddHpropertiesToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :hproperties, :hstore
  end
end
