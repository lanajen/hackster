class Favorite < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  attr_accessible :project_id, :user_id
  validates :user_id, uniqueness: { scope: :project_id }

  def self.create_for user, project
    create user_id: user.id, project_id: project.id
  end

  def self.destroy_for user, project
    where(user_id: user.id, project_id: project.id).destroy_all
  end
end
