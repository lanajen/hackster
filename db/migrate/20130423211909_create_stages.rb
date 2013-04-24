class CreateStages < ActiveRecord::Migration
  def change
    create_table :stages do |t|
      t.integer :project_id, null: false
      t.string :name
      t.integer :completion_rate, default: 0

      t.timestamps
    end
    add_index :stages, :project_id
  end
end
