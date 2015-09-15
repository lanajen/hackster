class PartObserver < ActiveRecord::Observer
  def after_commit record
    update_platform_counters record if record.platform_id.present?
  end

  def after_destroy record
    update_platform_counters record if record.platform_id.present?
  end

  def after_update record
    if record.platform_id.present? and (record.platform_id_changed? or record.private_changed?)
      record.projects.each do |project|
        project.update_counters only: [record.identifier.pluralize.to_sym]
        ProjectWorker.perform_async 'update_platforms', project.id
      end
    end
    if (record.changed & %w(slug name store_link product_page_link)).any?
      keys = []
      record.projects.pluck(:id).each do |id|
        keys += ["project-#{id}-#{record.identifier}-parts", "project-#{id}-left-column", "project-#{id}"]
      end
      Cashier.expire *keys if keys.any?
    end
  end

  private
    def update_platform_counters record
      record.platform.update_counters only: [:parts, :sub_parts, :sub_platforms]
    end
end