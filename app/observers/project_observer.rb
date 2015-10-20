class ProjectObserver < BaseArticleObserver
  def before_create record
    record.private_issues = record.private_logs = !!!record.open_source
    super
  end
end