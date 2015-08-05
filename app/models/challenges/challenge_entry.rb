class ChallengeEntry < ActiveRecord::Base
  self.table_name = :challenge_projects

  AWARDED_STATES = %w(awarded fullfiled)
  APPROVED_STATES = AWARDED_STATES + %w(qualified unawarded)

  include HstoreCounter
  include Workflow

  belongs_to :challenge
  belongs_to :project
  belongs_to :user
  has_and_belongs_to_many :prizes
  has_many :votes, as: :respectable, class_name: 'Respect', dependent: :destroy
  has_one :address, as: :addressable

  validates :challenge_id, uniqueness: { scope: :project_id }

  attr_accessible :judging_notes, :prize_ids

  counters_column :counters_cache
  has_counter :votes, 'votes.count'

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
    joins(:prizes).order("prizes.position ASC")
  end

  def approve
    notify_observers(:after_approve)
  end

  def awarded?
    workflow_state.in? AWARDED_STATES and has_prize?
  end

  def give_award
    notify_observers(:after_award_given)
  end

  def give_no_award
    notify_observers(:after_award_not_given)
  end

  def has_prize?
    prizes.any?
  end

  def shipping_required_for_prizes?
    prizes.select{|p| p.requires_shipping? }.any?
  end

  def to_tracker
    {}
  end
end
