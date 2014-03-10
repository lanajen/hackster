class IssueObserver < ActiveRecord::Observer
  def after_create record
    BaseMailer.enqueue_email 'new_issue_notification',
      { context_type: 'issue', context_id: record.id }
  end
end