class RemoveWebsites < ActiveRecord::Migration
  def up
    remove_index :websites, :user_id
    drop_table :websites
    add_column :users, :websites, :text
  end

  def down
  end
end
