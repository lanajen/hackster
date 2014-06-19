class CreateProjectGroups < ActiveRecord::Migration
  def change
    create_table :group_relations do |t|
      t.integer :project_id, null: false
      t.integer :group_id, null: false
      t.string :workflow_state, limit: 30
      t.timestamps
    end
    add_index :group_relations, :group_id
    add_index :group_relations, :project_id
  end
end
