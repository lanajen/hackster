class ChangeUsers < ActiveRecord::Migration
  def up
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :status
    add_column :users, :name, :string
    change_column :users, :bio, :string, limit: 160
    rename_column :users, :bio, :mini_resume
  end

  def down
  end
end
