class ChallengeRegistration < ActiveRecord::Base
  belongs_to :challenge
  belongs_to :user
  validates :challenge_id, uniqueness: { scope: :user_id }

  def self.has_registered? challenge, user
    exists? challenge_id: challenge.id, user_id: user.id
  end
end
