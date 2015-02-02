class CreatePartJoins < ActiveRecord::Migration
  def change
    create_table :part_joins do |t|
      t.integer :part_id, null: false
      t.integer :partable_id, null: false
      t.string :partable_type, null: false
      t.integer :quantity, default: 1
      t.string :unquantifiable_amount
      t.float :total_cost
      t.text :comment
      t.integer :position, default: 0, null: false

      t.timestamps
    end
    add_index :part_joins, :part_id
    add_index :part_joins, [:partable_id, :partable_type, :position]
  end
end
