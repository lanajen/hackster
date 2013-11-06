class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.integer :group_id, null: false
      t.integer :user_id, null: false
      t.string :title
      t.integer :group_roles_mask
      t.string :mini_resume

      t.timestamps
    end
    add_index :members, :group_id
    add_index :members, :user_id
  end
end
