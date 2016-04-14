class PartObserverWorker < BaseWorker
  sidekiq_options unique: :all, queue: :critical

  def after_commit record
    update_platform_counters record if record.platform_id.present?
  end

  def after_destroy record
    update_platform_counters record if record.platform_id.present?
  end

  def after_update record, changed
    if (%w(platform_id platform_ids) & changed).any? or (record.platform_id.present? and 'private'.in? changed)
      record.projects.each do |project|
        project.update_counters only: [record.identifier.pluralize.to_sym]
        ProjectWorker.perform_async 'update_platforms', project.id
      end
    end
    if (changed & %w(slug name store_link product_page_link image)).any?
      keys = []
      record.projects.pluck(:id).each do |id|
        keys += ["project-#{id}-#{record.identifier}-parts", "project-#{id}-left-column", "project-#{id}"]
      end
      Cashier.expire *keys if keys.any?
    end
  end

  def after_platforms_changed record
    record.projects.each do |project|
      ProjectWorker.perform_async 'update_platforms', project.id
    end
  end

  def perform method, record_id, *args
    with_logging method do
      record = Part.find record_id
      send(method, record, *args)
    end
  rescue ActiveRecord::RecordNotFound, Timeout::Error => e
    message = "Error while working on '#{method}' in '#{self.class.name}' with args #{args}: \"#{e.message}\""
    Rails.logger.error message
    log_line = LogLine.create(message: message, log_type: 'error', source: 'worker')
  end

  private
    def update_platform_counters record
      record.platform.update_counters only: [:parts, :sub_parts, :sub_platforms]
    end
end