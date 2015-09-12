class PartJoinObserver < ActiveRecord::Observer
  def after_commit_on_create record
    update_counters record if record.part_id.present?
    update_project record
    expire_cache record if record.partable_id.present?
  end

  def after_destroy record
    update_counters record if record.part_id.present?
    expire_cache record if record.partable_id.present?
  end

  def after_update record
    update_counters record if record.part_id_changed?
    if (record.changed & %w(part_id partable_id partable_type)).any?
      update_project record
    end
    expire_cache record if record.partable_id_changed? or record.comment_changed?
  end

  private
    def expire_cache record
      project = case record.partable
      when Project
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
      return unless record.part and record.part.platform and ((record.partable.class.name == 'PartsWidget' and record.partable.project) or record.partable.class.name == 'Project')

      project = case record.partable
      when Project
        record.partable
      when Widget
        record.partable.project
      end
      project.update_counters only: [record.part.identifier.pluralize.to_sym]
      ProjectWorker.perform_async 'update_platforms', project.id
    end
end