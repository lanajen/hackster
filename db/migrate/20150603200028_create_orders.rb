class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :total_cost
      t.integer :products_cost
      t.integer :shipping_cost
      t.integer :address_id
      t.string :workflow_state
      t.string :tracking_number
      t.integer :user_id, null: false
      t.hstore :counters_cache

      t.timestamps null: false
    end
    add_index :orders, :user_id
  end
end
