class PostObserver < ActiveRecord::Observer
  def after_create record
    update_counters record
    expire_project record
  end

  def after_destroy record
    update_counters record
    expire_project record
  end

  def after_update record
    expire_project record
  end

  private
    def expire_project record
      Cashier.expire "project-#{record.threadable_id}-#{model_type}" if record.threadable_type == 'BaseArticle'
    end

    def update_counters record
      record.threadable.update_counters only: [model_type]
      # Cashier.expire "project-#{record.threadable_id}-teaser"
    end
end