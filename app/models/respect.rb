class Respect < ActiveRecord::Base
  include Notifiable

  belongs_to :respectable, polymorphic: true
  belongs_to :user
  attr_accessible :respectable_id, :respectable_type, :user_id
  # allow for non unique respects for challenge_entry (= anonymous votes)
  validates :user_id, uniqueness: { scope: [:respectable_id, :respectable_type] }, unless: proc{|r| r.respectable_type == 'ChallengeEntry' }
  validate :user_is_not_team_member

  def self.create_for user, respectable
    if user
      user.respects.create respectable_id: respectable.id, respectable_type: respectable.model_name.to_s
    else
      Respect.create respectable_id: respectable.id, respectable_type: respectable.model_name.to_s, user_id: 0
    end
  end

  def self.destroy_for user, respectable
    if user
      user.respects.where(respectable_id: respectable.id, respectable_type: respectable.model_name.to_s).destroy_all
    else
      Respect.where(respectable_id: respectable.id, respectable_type: respectable.model_name.to_s, user_id: 0).last.try(:destroy)
    end
  end

  def self.to_be? user, respectable
    where(respectable_id: respectable.id, respectable_type: respectable.model_name.to_s, user_id: user.id).any?
  end

  def association_name_for_notifications
    respectable_type
  end

  private
    def user_is_not_team_member
      errors.add :base, "You can't respect your own project!" if respectable_type == 'Project' and user and user.is_team_member?(respectable)
    end
end
