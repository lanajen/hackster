class AddPropertiesToStoreProduct < ActiveRecord::Migration
  def change
    add_column :store_products, :properties, :hstore
  end
end
