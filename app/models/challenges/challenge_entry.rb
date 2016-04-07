class ChallengeEntry < ActiveRecord::Base
  self.table_name = :challenge_projects

  AWARDED_STATES = %w(awarded fullfiled)
  APPROVED_STATES = AWARDED_STATES + %w(qualified unawarded)

  include HstoreColumn
  include HstoreCounter
  include Workflow

  belongs_to :category, class_name: 'ChallengeCategory'
  belongs_to :challenge
  belongs_to :project, class_name: 'BaseArticle'
  belongs_to :user
  has_and_belongs_to_many :prizes
  has_many :notifications, as: :notifiable, dependent: :delete_all
  has_many :votes, as: :respectable, class_name: 'Respect', dependent: :destroy
  has_one :address, as: :addressable

  attr_accessible :judging_notes, :prize_ids, :workflow_state, :category_id,
    :project_id, :user_id

  validates :project_id, uniqueness: { scope: :challenge_id, message: 'has already been submitted to the contest' }
  validates :category_id, presence: true, if: proc{|e| e.challenge.activate_categories? }
  validate :validate_custom_fields_presence
  after_initialize :set_extra_fields

  counters_column :counters_cache
  has_counter :votes, 'votes.count'

  workflow do
    state :new do
      event :approve, transitions_to: :qualified
      event :disqualify, transitions_to: :unqualified
      event :give_award, transitions_to: :awarded
      event :give_no_award, transitions_to: :unawarded
    end
    state :unqualified do
      event :approve, transitions_to: :qualified
    end
    state :qualified do
      event :disqualify, transitions_to: :unqualified
      event :give_award, transitions_to: :awarded
      event :give_no_award, transitions_to: :unawarded
    end
    state :unawarded
    state :awarded do
      event :mark_prize_shipped, transitions_to: :fullfiled
    end
    state :fullfiled
    after_transition do |from, to, triggering_event, *event_args|
      notify_observers(:"after_#{triggering_event}")
    end
  end

  def self.approved
    where(workflow_state: APPROVED_STATES)
  end

  def self.winning
    joins(:prizes).order("prizes.position ASC")
  end

  def awarded?
    workflow_state.in? AWARDED_STATES and has_prize?
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

  # WARNING!
  # this function adds the fields to ChallengeEntry every time an instance is loaded.
  # since classes are cached on prod, it can cause duplicate attributes to be added.
  # moreover, there is cross-polenization between challenges, which causes bugs.
  # we've left hstore_column because it's begnign, but validation has to be taken out
  def set_extra_fields
    return unless challenge

    challenge.challenge_entry_fields.each_with_index do |field, i|
      field_name = "cfield#{i}"
      unless respond_to? field_name
        self.class.send :hstore_column, :properties, field_name, :text
        # self.class.send :validates, field_name, presence: true if field.required
      end
    end
  end

  private
    def validate_custom_fields_presence
      challenge.challenge_entry_fields.each_with_index do |field, i|
        field_name = "cfield#{i}"
        errors.add field_name, 'is required' if field.required and send(field_name).blank?
      end
    end
end
