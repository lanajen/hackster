class CreateStoreProducts < ActiveRecord::Migration
  def change
    create_table :store_products do |t|
      t.integer :source_id, null: false
      t.string :source_type, null: false
      t.integer :unit_cost, default: 0
      t.hstore :counters_cache
      t.boolean :available, default: false

      t.timestamps null: false
    end
    add_index :store_products, [:source_id, :source_type]
    add_index :store_products, :available
    add_index :store_products, :unit_cost
  end
end
