class CreateParts < ActiveRecord::Migration
  def change
    create_table :parts do |t|
      t.integer :quantity
      t.float :unit_price
      t.float :total_cost
      t.string :name
      t.string :vendor_name
      t.string :vendor_sku
      t.string :vendor_link
      t.string :partable_type, null: false
      t.integer :partable_id, null: false

      t.timestamps
    end
    add_index :parts, [:partable_id, :partable_type], name: 'partable_index'
  end
end
