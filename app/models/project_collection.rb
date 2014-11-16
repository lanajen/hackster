class ProjectCollection < ActiveRecord::Base
  include Workflow

  VALID_STATES = %w(featured approved)

  belongs_to :collectable, polymorphic: true
  belongs_to :project

  validates :project_id, uniqueness: { scope: [:collectable_id, :collectable_type] }

  after_create :approve!, if: proc {|p| p.can_approve? }

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
  end

  def self.assignment_or_event_for_project? project_id
    where(project_id: project_id, collectable_type: %w(Event Assignment)).any?
  end

  def self.featured
    where(workflow_state: 'featured')
  end

  def self.exists? project_id, collectable_type, collectable_id
    where(project_id: project_id, collectable_type: collectable_type, collectable_id: collectable_id).any?
  end

  def self.visible
    where(workflow_state: VALID_STATES)
  end
end
