class ReviewDecision < ActiveRecord::Base
  include HstoreColumn

  DECISIONS = {
    approved: 'Approved',
    needs_work: 'Needs work',
    rejected: 'Rejected',
  }.freeze
  FEEDBACK_FIELDS = {
    type: 'Template',
    content_type: 'Content type',
    name: 'Title',
    one_liner: 'Pitch',
    cover_image_id: 'Cover image',
    difficulty: 'Skill level',
    product_tags_string: 'Tags',
    team: 'Team',
    communities: 'Communities',
    story_json: 'Story',
    hardware_parts: 'Components',
    tool_parts: 'Tools',
    schematics: 'Schematics',
    cad: 'CAD',
    code: 'Code',
    software_parts: 'Apps and online services',
  }.freeze
  REJECTION_REASONS = {
    ad_spam: 'Ad or spam',
    commercial: 'Commercial',
    not_hardware: 'Not hardware',
    other: 'Other',
  }

  belongs_to :review_thread
  belongs_to :user
  has_one :project, through: :review_thread

  attr_accessible :decision

  FEEDBACK_FIELDS.keys.each do |field|
    hstore_column :feedback, field, :string
  end
  hstore_column :feedback, :no_changes_needed, :boolean
  hstore_column :feedback, :general, :string
  hstore_column :feedback, :rejection_reason, :string

  after_create :update_thread_status
  after_update :update_after_approved, if: proc{ |d| d.approved_changed? and d.approved }

  # validate :has_at_least_one_field_selected

  private
    def update_thread_status
      review_thread.update_column :workflow_state, :feedback_given if decision == :needs_work

      NotificationCenter.notify_all :new, :review_decision, id
    end

    def update_project_status
      case decision
      when 'approve'
        project.update_attribute :workflow_state, :approved
        review_thread.update_column :workflow_state, :closed
      when 'reject'
        project.update_attribute :workflow_state, :rejected
        review_thread.update_column :workflow_state, :closed
      end
    end

    # def has_at_least_one_field_selected
    #   errors.add :base, 'at least one field needs to be selected' unless (FEEDBACK_FIELDS.keys + %i(no_changes_needed rejection_reason)).select{|f| send(f).present? }.any?
    # end

    # def rejection_reason_is_given
    #   errors.add :rejection_reason, 'is required' if rejection_reason.empty? and decision == :rejected
    # end
end