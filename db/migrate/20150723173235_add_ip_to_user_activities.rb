class AddIpToUserActivities < ActiveRecord::Migration
  def change
    add_column :user_activities, :ip, :string
  end
end
