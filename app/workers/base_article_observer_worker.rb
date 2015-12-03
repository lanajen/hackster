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
    record.team.destroy if record.team
    record.purge
  end

  def after_update record, private_changed
    if private_changed
      update_counters record, [:live_projects]
      record.commenters.each{|u| u.update_counters only: [:comments] }
      keys = []
      record.users.each { |u| keys << "user-#{u.id}" }
      Cashier.expire *keys
      record.users.each { |u| u.purge }
    end
    record.purge
  end

  def after_approved record
    ProjectWorker.perform_async 'update_platforms', record.id

    if record.made_public_at.nil?
      record.post_new_tweet! if record.should_tweet?
      record.made_public_at = Time.now
    elsif record.made_public_at > Time.now
      record.post_new_tweet_at! record.made_public_at if record.should_tweet?
    end

    # actions common to both statements above
    if record.made_public_at.nil? or record.made_public_at > Time.now
      record.save
      NotificationCenter.notify_all :approved, :base_article, record.id
    end

    update_counters record, :approved_projects
  end

  def after_rejected record
    record.update_column :hide, true
    update_counters record, :approved_projects
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
    def update_counters record, type
      record.users.each{ |u| u.update_counters only: [type].flatten }
    end
end