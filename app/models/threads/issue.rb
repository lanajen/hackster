class Issue < Post
  include Workflow
  has_one :assignee_issue
  has_one :assignee, through: :assignee_issue
  attr_accessible :assignee_id

  workflow do
    state :open do
      event :close, transitions_to: :closed
    end
    state :closed do
      event :reopen, transitions_to: :open
    end
  end

  def self.closed
    where(workflow_state: :closed)
  end

  def self.open
    where(workflow_state: :open)
  end

  def assignee_id
    assignee_issue.try(:assignee_id)
  end

  def assignee_id=(val)
    if val.present?
      build_assignee_issue unless assignee_issue
      assignee_issue.assignee_id = val
    else
      assignee_issue.destroy if assignee_issue.present?
    end
  end

  def participants
    (commenters + [user]).uniq
  end

  private
    def generate_sub_id
      self.sub_id = threadable.issues.size + 1
    end
end
