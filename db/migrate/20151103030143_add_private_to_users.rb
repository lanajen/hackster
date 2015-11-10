class AddPrivateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :private, :boolean, default: false
    add_index :users, :private
  end
end
