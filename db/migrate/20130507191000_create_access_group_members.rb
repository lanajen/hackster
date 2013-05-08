class CreateAccessGroupMembers < ActiveRecord::Migration
  def change
    create_table :access_group_members do |t|
      t.integer :access_group_id
      t.integer :user_id

      t.timestamps
    end
    add_index :access_group_members, :access_group_id
    add_index :access_group_members, :user_id
  end
end
