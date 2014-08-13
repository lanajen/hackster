class BlogPostObserver < PostObserver
  def after_update record
    update_counters record if record.draft_changed?
  end

  private
    def model_type
      :build_logs
    end
end