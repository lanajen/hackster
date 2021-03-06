class AttachmentObserver < ActiveRecord::Observer
  def after_process record
    if record.attachable_type == 'BaseArticle'
      case record.type
      when 'CoverImage'
        id = record.attachable_id
        keys = []
        keys << "project-#{id}-teaser"
        keys << "project-#{id}-left-column"
        keys << "project-#{id}"
        keys << "project-#{id}-thumb"
        Cashier.expire *keys
      when 'Image'
        id = record.attachable_id
        keys = []
        keys << "project-#{id}-widgets"
        keys << "project-#{id}-left-column"
        keys << "project-#{id}"
        Cashier.expire *keys
      end
    elsif record.attachable_type == 'Widget'
      record.attachable.try(:touch)
    elsif record.attachable_type == 'Part'
      case record.type
      when 'Image'
        keys = []
        record.attachable.projects.pluck(:id).each do |id|
          keys += ["project-#{id}-#{record.attachable.identifier}-parts", "project-#{id}-left-column", "project-#{id}"]
        end
        Cashier.expire *keys if keys.any?
      end
    elsif record.attachable_type.in? %w(List)
      case record.type
      when 'CoverImage'
        Cashier.expire "list-#{record.attachable_id}-thumb", 'lists-index' if record.attachable.publyc?
      end
    elsif record.attachable_type.in? %w(Platform)
      case record.type
      when 'Avatar'
        Cashier.expire "platform-#{record.attachable_id}-sidebar"
      when 'Logo'
        Cashier.expire "platform-#{record.attachable_id}-client-nav"
      end
    elsif record.attachable_type == 'User'
      case record.type
      when 'Avatar'
        user = record.attachable
        Cashier.expire "user-#{user.id}-sidebar", "user-#{user.id}-thumb"
        FastlyWorker.perform_async 'purge', user.record_key
      end
    elsif record.attachable_type == 'Prize'
      case record.type
      when 'Image'
        challenge = record.attachable.challenge
        Cashier.expire "challenge-#{challenge.id}-prizes"
        FastlyWorker.perform_async 'purge', challenge.record_key
      end
    elsif record.attachable_type == 'Challenge'
      challenge = record.attachable
      Cashier.expire "challenge-#{challenge.id}-meta", "challenge-#{challenge.id}-banner", 'challenge-index'
      FastlyWorker.perform_async 'purge', challenge.record_key
    end
    if record.attachable_type != 'Orphan' and record.attachable
      FastlyWorker.perform_async 'purge', record.attachable.record_key
      record.attachable.update_attribute :updated_at, Time.now if record.attachable.respond_to? :updated_at
    end
  end

  alias_method :after_update, :after_process
end
