class AddAttributesToStoreProducts < ActiveRecord::Migration
  def change
    add_column :store_products, :name, :string
    add_column :store_products, :description, :text
  end
end
