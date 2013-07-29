class AddProfileUrlToInviteRequests < ActiveRecord::Migration
  def change
    add_column :invite_requests, :profile_url, :string
    add_column :invite_requests, :twitter_username, :string
  end
end
