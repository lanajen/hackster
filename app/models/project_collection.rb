class ProjectCollection < ActiveRecord::Base
  include Workflow

  VALID_STATES = %w(featured approved)

  belongs_to :collectable, polymorphic: true
  belongs_to :project

  validates :project_id, uniqueness: { scope: [:collectable_id, :collectable_type] }

  after_create :update_status

  # scope :visible, -> { where(workflow_state: VALID_STATES) }

  workflow do
    state :new do
      event :approve, transitions_to: :approved
      event :require_review, transitions_to: :pending_review
    end
    state :pending_review do
      event :approve, transitions_to: :approved
      event :reject, transitions_to: :rejected
    end
    state :featured do
      event :unfeature, transitions_to: :approved
    end
    state :approved do
      event :feature, transitions_to: :featured
      event :reject, transitions_to: :rejected
    end
    state :rejected do
      event :approve, transitions_to: :approved
    end
    after_transition do |from, to, triggering_event, *event_args|
      notify_observers 'after_status_updated' if to.to_s.in? %w(approved rejected)
    end
  end

  def self.assignment_or_event_for_project? project_id
    where(project_id: project_id, collectable_type: %w(Event Assignment)).any?
  end

  def self.exists? project_id, collectable_type, collectable_id
    super(project_id: project_id, collectable_type: collectable_type, collectable_id: collectable_id)
  end

  def self.featured
    where(workflow_state: 'featured')
  end

  def self.most_recent
    order(created_at: :desc)
  end

  def self.visible
    where(workflow_state: VALID_STATES)
  end

  private
    def update_status
      if collectable.class.name == 'Platform'
        require_review!
      else
        approve!
      end
    end
end
