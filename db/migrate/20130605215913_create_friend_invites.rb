class CreateFriendInvites < ActiveRecord::Migration
  def change
    create_table :friend_invites do |t|

      t.timestamps
    end
  end
end
