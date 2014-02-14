class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.integer :promotion_id, null: false
      t.integer :id_for_promotion, null: false
      t.string :name

      t.timestamps
    end
    add_index :assignments, :promotion_id
    add_index :assignments, :id_for_promotion
  end
end
