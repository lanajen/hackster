class CreateWidgets < ActiveRecord::Migration
  def change
    create_table :widgets do |t|
      t.string :type, null: false
      t.integer :stage_id, null: false
      t.text :properties
      t.integer :completion_rate, default: 0
      t.integer :completion_share, default: 0
      t.string :name

      t.timestamps
    end
    add_index :widgets, :stage_id
  end
end
