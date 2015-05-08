class ChallengeEntry < ActiveRecord::Base
  self.table_name = :challenge_projects

  AWARDED_STATES = %w(awarded fullfiled)
  APPROVED_STATES = AWARDED_STATES + %w(qualified unawarded)

  include Workflow

  belongs_to :challenge
  belongs_to :prize
  belongs_to :project
  belongs_to :user
  has_one :address, as: :addressable

  validates :challenge_id, uniqueness: { scope: :project_id }

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

  def self.approved
    where(workflow_state: APPROVED_STATES)
  end

  def self.winning
    where("challenge_projects.prize_id IS NOT NULL").joins("INNER JOIN prizes ON challenge_projects.prize_id = prizes.id").order("prizes.position ASC")
  end

  def approve
    notify_observers(:after_approve)
  end

  def awarded?
    workflow_state.in? AWARDED_STATES and prize_id.present?
  end

  def give_award
    notify_observers(:after_award_given)
  end

  def give_no_award
    notify_observers(:after_award_not_given)
  end
end
