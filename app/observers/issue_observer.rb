class IssueObserver < PostObserver
  def after_create record
    super record
    BaseMailer.enqueue_email 'new_issue_notification',
      { context_type: 'issue', context_id: record.id }
    update_counters record
  end

  def after_destroy record
    update_counters record
  end

  private
    def update_counters record
      record.threadable.update_counters only: [:issues]
      Cashier.expire "project-#{record.threadable_id}-teaser"
    end

    def widget_type
      'IssueWidget'
    end
end