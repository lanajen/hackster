class AddHidToCommentsAndUsers < ActiveRecord::Migration
  def change
    add_column :comments, :hid, :string, limit: 16
    add_index :comments, :hid

    add_column :users, :hid, :string, limit: 16
    add_index :users, :hid
  end
end
