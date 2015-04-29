class AttachmentObserver < ActiveRecord::Observer
  def after_process record
    if record.attachable_type == 'Project'
      record.attachable.purge
      case record.type
      when 'CoverImage'
        Cashier.expire "project-#{record.attachable_id}-teaser"
        Cashier.expire "project-#{record.attachable_id}-thumb"
      when 'Image'
        Cashier.expire "project-#{record.attachable_id}-widgets"
      end
    elsif record.attachable_type == 'Widget'
      case record.type
      when 'Image'
        Cashier.expire "project-#{record.attachable.widgetable_id}-widgets"
      end
    elsif record.attachable_type.in? %w(Platform)
      record.attachable.purge
      case record.type
      when 'Avatar'
        Cashier.expire "platform-#{record.attachable_id}-sidebar"
      when 'Logo'
        Cashier.expire "platform-#{record.attachable_id}-client-nav"
      end
    end
    record.attachable.update_attribute :updated_at, Time.now if record.attachable
  end
end