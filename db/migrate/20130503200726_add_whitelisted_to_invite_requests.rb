class AddWhitelistedToInviteRequests < ActiveRecord::Migration
  def change
    add_column :invite_requests, :whitelisted, :boolean
    add_column :invite_requests, :user_id, :integer, null: false, default: 0
    add_index :invite_requests, :user_id
  end
end