class IssueObserver < PostObserver
  def after_commit_on_create record
    BaseMailer.enqueue_email 'new_issue_notification',
      { context_type: 'issue', context_id: record.id } if record.type == 'Issue'
  end

  private
    def model_type
      :issues
    end
end