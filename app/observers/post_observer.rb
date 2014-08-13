class PostObserver < BaseBroadcastObserver
  def after_create record
    update_counters record
  end

  def after_destroy record
    update_counters record
  end

  private
    def update_counters record
      record.threadable.update_counters only: [model_type]
      # Cashier.expire "project-#{record.threadable_id}-teaser"
    end
end