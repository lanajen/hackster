class RemoveUserIdFromProjects < ActiveRecord::Migration
  def up
    remove_index :projects, :user_id
    remove_column :projects, :user_id
  end

  def down
    add_column :projects, :user_id, :integer, null: false
    add_index :projects, :user_id
  end
end
