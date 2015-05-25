class CreateLinkedParts < ActiveRecord::Migration
  def change
    create_table :part_relations do |t|
      t.integer :parent_part_id
      t.integer :child_part_id
    end
    add_index :part_relations, :parent_part_id
    add_index :part_relations, :child_part_id
  end
end
