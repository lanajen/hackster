class AddNotificationsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :notifications, :text
  end
end
