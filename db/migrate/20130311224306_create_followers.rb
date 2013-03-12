class CreateFollowers < ActiveRecord::Migration
  def change
    create_table :follow_relations do |t|
      t.integer :follower_id, null: false
      t.integer :followed_id, null: false

      t.timestamps
    end
    add_index :follow_relations, :follower_id
    add_index :follow_relations, :followed_id
  end
end
