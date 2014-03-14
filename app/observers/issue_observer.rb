class IssueObserver < PostObserver
  def after_create record
    super record
    BaseMailer.enqueue_email 'new_issue_notification',
      { context_type: 'issue', context_id: record.id }
  end

  private
    def widget_type
      'IssueWidget'
    end
end