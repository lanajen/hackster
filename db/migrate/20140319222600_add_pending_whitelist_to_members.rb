class AddPendingWhitelistToMembers < ActiveRecord::Migration
  def change
    add_column :members, :requested_to_join_at, :datetime
    add_column :members, :approved_to_join, :boolean
  end
end
