class AddStuffToUserActivities < ActiveRecord::Migration
  def change
    add_column :user_activities, :session_id, :string, limit: 40
    add_column :user_activities, :request_url, :string
    add_column :user_activities, :referrer_url, :string
    add_column :user_activities, :landing_url, :string
    add_column :user_activities, :initial_referrer, :string
  end
end
