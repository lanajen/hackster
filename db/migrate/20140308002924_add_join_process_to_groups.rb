class AddJoinProcessToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :access_level, :string
    add_column :groups, :invitation_token, :string, limit: 30
  end
end
