class Respect < ActiveRecord::Base
  include Notifiable

  belongs_to :respectable, polymorphic: true
  belongs_to :user
  attr_accessible :respectable_id, :respectable_type, :user_id
  validates :user_id, uniqueness: { scope: [:respectable_id, :respectable_type] }
  validate :user_is_not_team_member

  def self.create_for user, respectable
    user.respects.create respectable_id: respectable.id, respectable_type: respectable.class.name
  end

  def self.destroy_for user, respectable
    user.respects.where(respectable_id: respectable.id, respectable_type: respectable.class.name).destroy_all
  end

  def self.to_be? user, respectable
    where(respectable_id: respectable.id, respectable_type: respectable.class.name, user_id: user.id).any?
  end

  def association_name_for_notifications
    respectable_type
  end

  private
    def user_is_not_team_member
      errors.add :base, "You can't respect your own project!" if respectable_type == 'Project' and user and user.is_team_member?(respectable)
    end
end
