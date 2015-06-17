class PartObserver < ActiveRecord::Observer
  def after_commit record
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
    keys = []
    record.projects.pluck(:id).each do |id|
      keys += ["project-#{id}-#{record.class.name.underscore.gsub(/_part/, '')}-parts", "project-#{id}-left-column", "project-#{id}"]
    end
    Cashier.expire *keys if keys.any?
  end

  private
    def update_platform_counters record
      record.platform.update_counters only: [:parts, :sub_parts, :sub_platforms]
    end
end