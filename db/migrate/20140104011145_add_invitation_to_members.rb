class AddInvitationToMembers < ActiveRecord::Migration
  def change
    add_column :members, :invitation_accepted_at, :datetime
    add_column :members, :invitation_sent_at, :datetime
    add_column :members, :invited_by_id, :integer
    add_column :members, :invited_by_type, :string
  end
end
