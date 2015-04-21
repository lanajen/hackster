class IssueObserver < PostObserver
  def after_commit_on_create record
    NotificationCenter.notify_all :new, :issue, record.id if record.type == 'Issue'
  end

  private
    def model_type
      :issues
    end
end