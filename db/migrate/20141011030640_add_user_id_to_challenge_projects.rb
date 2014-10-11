class AddUserIdToChallengeProjects < ActiveRecord::Migration
  def change
    add_column :challenge_projects, :user_id, :integer
  end
end
