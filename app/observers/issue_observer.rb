class IssueObserver < PostObserver
  def after_commit_on_create record
    BaseMailer.enqueue_email 'new_issue_notification',
      { context_type: 'issue', context_id: record.id }
  end

  def after_create record
    super record
    update_counters record
  end

  def after_destroy record
    update_counters record
  end

  private
    def update_counters record
      record.threadable.update_counters only: [:issues]
      # Cashier.expire "project-#{record.threadable_id}-teaser"
    end
end