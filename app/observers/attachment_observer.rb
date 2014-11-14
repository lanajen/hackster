class AttachmentObserver < ActiveRecord::Observer
  def after_process record
    if record.attachable_type.in? %w(Project Widget)
      case record.type
      when 'CoverImage'
        Cashier.expire "project-#{record.attachable_id}-teaser"
        Cashier.expire "project-#{record.attachable_id}-thumb"
      when 'Image'
        Cashier.expire "project-#{record.attachable_id}-widgets"
      end
    elsif record.attachable_type.in? %w(Tech)
      case record.type
      when 'Avatar'
        Cashier.expire "tech-#{record.attachable_id}-sidebar"
      when 'Logo'
        Cashier.expire "tech-#{record.attachable_id}-client-nav"
      end
    # elsif record.attachable_type == 'User'
    #   keys = ["user-#{record.attachable_id}-teaser", "user-#{record.attachable_id}-thumb", "user-#{record.attachable_id}-sidebar"]
    #   user = record.attachable
    #   user.teams.each{|t| keys << "team-#{t.id}-user-thumbs" }
    #   user.respected_projects.each{|p| keys << "project-#{p.id}-respects" }
    #   Cashier.expire *keys
    # elsif record.attachable_type == 'Tech'
    #   keys = record.followers.map{|u| "user-#{u.id}-sidebar" } + ["tech-#{record.id}-sidebar"]
    #   Cashier.expire *keys
    end
  end
end