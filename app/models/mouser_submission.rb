class MouserSubmission < ActiveRecord::Base

  belongs_to :projects
  belongs_to :user

  attr_accessible :project_id, :user_id, :vendor_user_name, :workflow_state

  validates :user_id, :project_id, :vendor_user_name, presence: true
  validates :project_id, uniqueness: { scope: :vendor_user_name }

  include Workflow
    workflow do
      state :new do
        event :approve, transitions_to: :approved
        event :reject, transitions_to: :rejected
      end
      state :approved
      state :rejected
    end

end