class ChallengeIdea < ActiveRecord::Base
  APPROVED_STATES = %w(approved won lost)

  include HstoreColumn
  include Workflow

  belongs_to :challenge, inverse_of: :ideas
  belongs_to :user
  has_one :image, as: :attachable, dependent: :destroy

  hstore_column :properties, :description, :text

  attr_accessible :name, :image_id

  validates :name, :description, :image_id, presence: true
  after_initialize :set_extra_fields

  workflow do
    state :new do
      event :approve, transitions_to: :approved
      event :reject, transitions_to: :rejected
    end
    state :approved do
      event :reject, transitions_to: :rejected
      event :mark_lost, transitions_to: :lost
      event :mark_won, transitions_to: :won
    end
    state :rejected do
      event :approve, transitions_to: :approved
    end
    state :won
    state :lost
    after_transition do |from, to, triggering_event, *event_args|
      notify_observers(:"after_#{triggering_event}")
    end
  end

  def self.approved
    where workflow_state: APPROVED_STATES
  end

  def image_id
    @image_id ||= image.try(:id)
  end

  def image_id=(val)
    @image_id = val
    self.image = Image.find_by_id(val)
  end

  def set_extra_fields
    return unless challenge

    challenge.challenge_idea_fields.each_with_index do |field, i|
      field_name = "cfield#{i}"
      self.class.send :hstore_column, :properties, field_name, :text
      self.class.send :validates, field_name, presence: true if field.required
    end
  end
end
