class PartJoinObserverWorker < BaseWorker
  sidekiq_options unique: :all, queue: :critical

  def after_commit_on_create record
    update_counters record if record.part_id.present?
    update_project record
    expire_cache record if record.partable_id.present?
  end

  def after_destroy record
    update_counters record if record.part_id.present?
    expire_cache record if record.partable_id.present?
  end

  def after_update record, changed
    if (changed & %w(part_id)).any?
      update_counters record
      update_project record
    end
    expire_cache record if (%w(comment part_id quantity) & changed).any?
  end

  def perform method, record_id, *args
    with_logging method do
      record = PartJoin.find record_id
      send(method, record, *args)
    end
  rescue ActiveRecord::RecordNotFound, Timeout::Error => e
    message = "Error while working on '#{method}' in '#{self.class.name}' with args #{args}: \"#{e.message}\""
    Rails.logger.error message
    log_line = LogLine.create(message: message, log_type: 'error', source: 'worker')
  end

  private
    def expire_cache record
      project = case record.partable
      when BaseArticle
        record.partable
      when Widget
        record.partable.widgetable
      end
      keys = ["project-#{project.id}-#{record.part.identifier}-parts", "project-#{project.id}-left-column", "project-#{project.id}"]
      Cashier.expire *keys
      project.purge
    end

    def update_counters record
      record.part.update_counters only: [:projects, :all_projects]
    end

    def update_project record
      return unless record.part and record.part.platform and ((record.partable.class.name == 'PartsWidget' and record.partable.project) or record.partable_type == 'BaseArticle')

      project = case record.partable
      when BaseArticle
        record.partable
      when Widget
        record.partable.project
      end
      project.update_counters only: [record.part.identifier.pluralize.to_sym]
      ProjectWorker.perform_async 'update_platforms', project.id
    end
end