class AddProjectIdToInviteRequests < ActiveRecord::Migration
  def change
    add_column :invite_requests, :project_id, :integer
  end
end
