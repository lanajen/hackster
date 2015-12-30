class ReviewThread < ActiveRecord::Base
  include Workflow

  belongs_to :project, class_name: 'BaseArticle', foreign_key: :project_id
  has_many :comments, as: :commentable
  has_many :decisions, class_name: 'ReviewDecision'
  # has_many :updates, class_name: 'ReviewUpdate'

  workflow do
    state :new
    state :needs_review
    state :feedback_given
    state :feedback_responded_to
    state :closed
  end
end
