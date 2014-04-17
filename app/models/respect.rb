class Respect < ActiveRecord::Base
  belongs_to :project
  belongs_to :respecting, polymorphic: true
  attr_accessible :project_id, :respecting_id, :respecting_type
  validates :respecting_id, uniqueness: { scope: [:project_id, :respecting_type] }
  validate :user_is_not_team_member

  def self.create_for respecting, project
    respecting.respects.create project_id: project.id
  end

  def self.destroy_for respecting, project
    respecting.respects.where(project_id: project.id).destroy_all
  end

  def user
    respecting if respecting.class == User
  end

  private
    def user_is_not_team_member
      errors.add :base, "You can't respect your own project!" if user and user.is_team_member?(project)
    end
end
