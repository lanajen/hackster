class GroupRelation < ActiveRecord::Base
  include Workflow

  VALID_STATES = %w(featured approved)

  belongs_to :group
  belongs_to :project
  after_create :update_workflow#, unless: proc {|g| g.project.external and g.project.approved.nil? }

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

  def self.visible
    where(workflow_state: VALID_STATES)
  end

  private
    def update_workflow
      approve!
    end
end