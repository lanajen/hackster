class ProjectCollection < ActiveRecord::Base
  include HstoreColumn
  include Workflow

  VALID_STATES = %w(featured approved)

  belongs_to :collectable, polymorphic: true
  belongs_to :project, class_name: 'BaseArticle'

  validates :project_id, uniqueness: { scope: [:collectable_id, :collectable_type] }

  after_create :update_status

  hstore_column :properties, :featured_position, :integer

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
      notify_observers 'after_status_updated', from if to.to_s.in? %w(approved rejected)
    end
  end

  def self.assignment_or_event_for_project? project_id
    where(project_id: project_id, collectable_type: %w(Event Assignment)).any?
  end

  def self.exists? project_id, collectable_type, collectable_id
    super(project_id: project_id, collectable_type: collectable_type, collectable_id: collectable_id)
  end

  def self.featured
    where(workflow_state: 'featured').order("CAST(project_collections.properties -> 'featured_position' AS INTEGER) ASC NULLS LAST")
  end

  def self.featured_order locale
    order("(CASE WHEN (project_collections.workflow_state = 'featured' AND projects.locale = '#{locale}') THEN (CASE WHEN CAST(project_collections.properties -> 'featured_position' AS INTEGER) IS NULL THEN 99 ELSE CAST(project_collections.properties -> 'featured_position' AS INTEGER) END) ELSE 100 END) ASC")
  end

  def self.most_recent
    order(created_at: :desc)
  end

  def self.visible
    where(workflow_state: VALID_STATES)
  end

  def featured? locale=nil
    (locale ? project.locale == locale : true) and workflow_state == 'featured'
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
