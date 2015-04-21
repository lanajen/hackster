class RenameNotificationsForUsers < ActiveRecord::Migration
  def change
    rename_column :users, :notifications, :properties
  end
end
