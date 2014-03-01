class CreateFollowRelations < ActiveRecord::Migration
  def up
    drop_table :project_followers
    drop_table :follow_relations
    create_table :follow_relations do |t|
      t.integer :user_id
      t.integer :followable_id
      t.string :followable_type

      t.timestamps
    end
    add_index :follow_relations, :user_id
    add_index :follow_relations, [:followable_id, :followable_type]
  end
end
