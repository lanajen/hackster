class PartObserver < ActiveRecord::Observer
  def after_commit_on_create record
    update_platform_counters record if record.platform_id.present?
  end

  def after_destroy record
    update_platform_counters record if record.platform_id.present?
  end

  def after_update record
    if record.platform_id_changed? and record.platform_id.present?
      record.projects.each do |project|
        platform_name = record.platform.name
        unless platform_name.in? project.platform_tags_array
          project.platform_tags_array += [platform_name]
          project.save
        end
      end
    end
  end

  private
    def update_platform_counters record
      record.platform.update_counters only: [:parts]
    end
end