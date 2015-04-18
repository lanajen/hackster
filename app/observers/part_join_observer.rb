class PartJoinObserver < ActiveRecord::Observer
  def after_commit_on_create record
    update_counters record if record.part_id.present?
    update_project record
  end

  def after_destroy record
    update_counters record if record.part_id.present?
  end

  def after_update record
    update_counters record if record.part_id_changed?
    if (record.changed & %w(part_id partable_id partable_type)).any?
      update_project record
    end
  end

  private
    def update_counters record
      record.part.update_counters only: [:projects]
    end

    def update_project record
      return unless record.part and record.part.platform and record.partable.class.name == 'PartsWidget' and record.partable.project

      project = record.partable.project
      platform_name = record.part.platform.name
      unless platform_name.in? project.platform_tags_array
        project.platform_tags_array += [platform_name]
        project.save
      end
    end
end