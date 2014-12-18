class FollowRelation < ActiveRecord::Base
  belongs_to :followable, polymorphic: true
  belongs_to :user

  validates :user_id, uniqueness: { scope: [:followable_id, :followable_type] }
  validate :following_someone_else

  attr_accessible :user_id, :followable_id, :followable_type

  def self.add user, followable, skip_notification=false
    rel = new user_id: user.id, followable_type: followable.class.model_name.to_s, followable_id: followable.id
    rel.skip_notification! if skip_notification
    rel.save
  end

  def self.destroy user, followable
    where(user_id: user.id, followable_type: followable.class.model_name.to_s, followable_id: followable.id).destroy_all
  end

  def skip_notification!
    @skip_notification = true
  end

  def skip_notification?
    @skip_notification
  end

  private
    def following_someone_else
      errors.add :user_id, "cannot follow yourself" if user_id == followable_id and followable_type == 'User'
    end
end
