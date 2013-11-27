class UpdateDeviseInvitable < ActiveRecord::Migration
  def change
    change_column :users, :invitation_token, :string, :limit => nil
    add_column :users, :invitation_created_at, :datetime
    add_index :users, :invitation_token, :unique => true
  end
end
