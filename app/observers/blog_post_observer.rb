class BlogPostObserver < PostObserver
  def after_create record
    super record
    update_counters record
  end

  def after_destroy record
    update_counters record
  end

  private
    def update_counters record
      record.threadable.update_counters only: [:build_logs]
      # Cashier.expire "project-#{record.threadable_id}-teaser"
    end
end