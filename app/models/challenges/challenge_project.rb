class ChallengeProject < ActiveRecord::Base
  AWARDED_STATES = %w(awarded fullfiled)

  include Workflow

  belongs_to :challenge
  belongs_to :prize
  belongs_to :project
  validates :challenge_id, uniqueness: { scope: :project_id }
  # validates :challenge_id, uniqueness: { scope: :prize_id }

  workflow do
    state :new do
      event :approve, transitions_to: :qualified
      event :reject, transitions_to: :unqualified
    end
    state :unqualified
    state :qualified do
      event :give_award, transitions_to: :awarded
      event :give_no_award, transitions_to: :unawarded
    end
    state :unawarded
    state :awarded do
      event :mark_prize_shipped, transitions_to: :fullfiled
    end
    state :fullfiled
  end
end
