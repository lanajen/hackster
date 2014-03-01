class FollowRelation < ActiveRecord::Base
  belongs_to :followable, polymorphic: true
  belongs_to :user

  validates :user_id, uniqueness: { scope: [:followable_id, :followable_type] }

  attr_accessible :user_id, :followable_id, :followable_type

  def self.add user, followable
    create user_id: user.id, followable_type: followable.class.name, followable_id: followable.id
  end

  def self.destroy user, followable
    where(user_id: user.id, followable_type: followable.class.name, followable_id: followable.id).destroy_all
  end

end
