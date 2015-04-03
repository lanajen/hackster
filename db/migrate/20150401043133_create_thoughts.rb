class CreateThoughts < ActiveRecord::Migration
  def change
    create_table :thoughts do |t|
      t.text :body
      t.integer :user_id, null: false

      t.timestamps
    end
    add_index :thoughts, :user_id
  end
end
