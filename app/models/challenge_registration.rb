class ChallengeRegistration < ActiveRecord::Base
  include HstoreColumn

  belongs_to :challenge
  belongs_to :user
  validates :challenge_id, uniqueness: { scope: :user_id }

  hstore_column :hproperties, :receive_sponsor_news, :boolean

  def self.has_registered? challenge, user
    exists? challenge_id: challenge.id, user_id: user.id
  end
end
