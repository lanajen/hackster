class CreateOrderLines < ActiveRecord::Migration
  def change
    create_table :order_lines do |t|
      t.integer :store_product_id, null: false
      t.integer :order_id, null: false
    end
    add_index :order_lines, :store_product_id
    add_index :order_lines, :order_id
  end
end
