class AddPropertiesToProjectCollections < ActiveRecord::Migration
  def change
    add_column :project_collections, :properties, :hstore
  end
end
