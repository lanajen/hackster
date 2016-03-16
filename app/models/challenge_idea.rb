class ChallengeIdea < ActiveRecord::Base
  APPROVED_STATES = %w(approved won lost)

  include HstoreColumn
  include Workflow

  belongs_to :address
  belongs_to :challenge, inverse_of: :ideas
  belongs_to :user
  has_many :notifications, as: :notifiable, dependent: :delete_all
  has_one :image, as: :attachable, dependent: :destroy

  hstore_column :properties, :description, :text

  attr_accessible :name, :image_id, :address_id, :address_attributes

  accepts_nested_attributes_for :address

  validates :name, :description, :image_id, presence: true
  validates :address, presence: true
  validate :validate_custom_fields_presence
  after_initialize :set_extra_fields

  workflow do
    state :new do
      event :approve, transitions_to: :approved
      event :reject, transitions_to: :rejected
    end
    state :approved do
      event :mark_needs_approval, transitions_to: :new
      event :reject, transitions_to: :rejected
    end
    state :rejected do
      event :mark_needs_approval, transitions_to: :new
      event :approve, transitions_to: :approved
    end
    after_transition do |from, to, triggering_event, *event_args|
      notify_observers(:"after_#{triggering_event}")
    end
  end

  def self.approved
    where workflow_state: APPROVED_STATES
  end

  def self.won
    where workflow_state: :won
  end

  def image_id
    @image_id ||= image.try(:id)
  end

  def image_id=(val)
    @image_id = val
    attribute_will_change! :image
    self.image = Image.find_by_id(val)
  end

  # WARNING!
  # this function adds the fields to ChallengeIdea every time an instance is loaded.
  # since classes are cached on prod, it can cause duplicate attributes to be added.
  # moreover, there is cross-polenization between challenges, which causes bugs.
  # we've left hstore_column because it's begnign, but validation has to be taken out
  def set_extra_fields
    return unless challenge

    challenge.challenge_idea_fields.each_with_index do |field, i|
      field_name = "cfield#{i}"
      unless respond_to? field_name
        self.class.send :hstore_column, :properties, field_name, :text
        # self.class.send :validates, field_name, presence: true if field.required
      end
    end
  end

  private
    def validate_custom_fields_presence
      challenge.challenge_idea_fields.each_with_index do |field, i|
        field_name = "cfield#{i}"
        errors.add field_name, 'is required' if field.required and send(field_name).blank?
      end
    end
end
