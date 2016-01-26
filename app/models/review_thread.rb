class ReviewThread < ActiveRecord::Base
  INACTIVE_STATES = %w(new closed)
  NEED_ATTENTION = %w(needs_review feedback_responded_to needs_second_review)
  include Workflow

  belongs_to :project, class_name: 'BaseArticle', foreign_key: :project_id, inverse_of: :review_thread
  has_many :comments, -> { order(:created_at) }, as: :commentable, dependent: :destroy
  has_many :decisions, -> { order(:created_at) }, class_name: 'ReviewDecision', dependent: :destroy
  has_many :events, -> { order(:created_at) }, class_name: 'ReviewEvent', dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :delete_all

  workflow do
    state :new
    state :needs_review
    state :feedback_given
    state :feedback_responded_to
    state :needs_second_review
    state :decision_made
    state :project_updated
    state :closed
  end

  def self.active
    where.not workflow_state: INACTIVE_STATES
  end

  def self.need_attention
    where workflow_state: NEED_ATTENTION
  end

  def decision
    decisions.last.try(:decision)
  end

  def open?
    !closed?
  end

  def participants
    @participants ||= User.where(id: comments.pluck(:user_id) + decisions.pluck(:user_id))
  end

  def ready_for_approval?
    open? and decisions.where(decision: %w(approve reject)).count >= 2
  end
end
