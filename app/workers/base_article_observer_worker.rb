class BaseArticleObserverWorker < BaseWorker
  sidekiq_options unique: :all, queue: :critical

  def after_create record
    update_counters record, :projects
  end

  def after_commit_on_update record, needs_platform_refresh, private_changed
    if needs_platform_refresh
      ProjectWorker.perform_async 'update_platforms', record.id
    end

    if private_changed
      record.parts.each do |part|
        part.update_counters only: [:projects]
      end
    end
  end

  def after_destroy record
    update_counters record, [:projects, :live_projects]
    FastlyWorker.perform_async 'purge', record.record_key
  end

  def after_update record, private_changed, changed
    fastly_keys = []
    if private_changed
      update_counters record, [:live_projects]
      record.commenters.each{|u| u.update_counters only: [:comments] }
      keys = []
      record.users.each { |u| keys << "user-#{u.id}" }
      Cashier.expire *keys
      fastly_keys = record.users.map { |u| u.record_key }
    end
    fastly_keys << record.record_key
    FastlyWorker.perform_async 'purge', *fastly_keys
  end

  def after_approved record
    ProjectWorker.perform_async 'update_platforms', record.id

    @notify = false
    if record.featured_date.nil?
      TwitterQueue.perform_in 1.minute, 'schedule_project_tweet', record.id if record.should_tweet?  # delay to give it time to run update_platforms
      record.update_column :featured_date, Time.now
      @notify = true
    elsif record.featured_date > Time.now
      TwitterQueue.perform_in 1.minute, 'schedule_project_tweet', record.id, record.featured_date if record.should_tweet?
      @notify = true
    end

    # actions common to both statements above
    if @notify
      NotificationCenter.notify_all :approved, :base_article, record.id
    end

    if record.review_thread
      record.review_thread.update_column :workflow_state, :closed
    end

    update_counters record, :approved_projects
    log_state_change record
  end

  def after_pending_review record
    record.update_column :made_public_at, Time.now if record.made_public_at.nil?

    if record.review_thread
      record.review_thread.update_attribute :workflow_state, :needs_review
    else
      record.create_review_thread
    end
    NotificationCenter.notify_via_email :published, :base_article, record.id
  end

  def after_rejected record
    record.update_column :hide, true
    update_counters record, :approved_projects
    log_state_change record
  end

  def perform method, record_id, *args
    with_logging method do
      record = BaseArticle.find record_id
      send(method, record, *args)
    end
  rescue ActiveRecord::RecordNotFound, Timeout::Error => e
    message = "Error while working on '#{method}' in '#{self.class.name}' with args #{args}: \"#{e.message}\""
    Rails.logger.error message
    log_line = LogLine.create(message: message, log_type: 'error', source: 'worker')
  end

  private
    def log_state_change record
      ProjectWorker.perform_async 'create_review_event', record.id, record.reviewer_id, :project_status_update, workflow_state: record.workflow_state
    end

    def update_counters record, type
      record.users.each{ |u| u.update_counters only: [type].flatten }
    end
end