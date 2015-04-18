class PartJoinObserver < ActiveRecord::Observer
  def after_commit_on_save record
    update_counters record if record.part_id.present?
    update_platform_counters record if record.platform_id.present?
  end

  def after_destroy record
    update_counters record if record.part_id.present?
    update_platform_counters record if record.platform_id.present?
  end

  def after_update record
    update_counters record if record.part_id_changed?
    update_platform_counters record if record.platform_id_changed?
  end

  private
    def update_counters record
      record.part.update_counters only: [:projects]
    end

    def update_platform_counters record
      record.platform.update_counters only: [:parts]
    end
end