class ProjectWorker < BaseWorker
  def update_platforms id
    return unless project = Project.find_by_id(id)

    if project.private?
      project.platforms.delete_all
    else
      project.platform_tags_cached.each do |tag|
        next unless platform = Platform.joins(:platform_tags).references(:tags).where("LOWER(tags.name) = ?", tag.downcase).first

        collection = ProjectCollection.where(collectable_id: platform.id, collectable_type: 'Group', project_id: project.id).first_or_create

        case platform.moderation_level
        when 'auto'
          puts platform.name + ': approved (auto)'
          collection.approve! if collection.can_approve?
        when 'hackster'
          if project.approved?
            puts platform.name + ': approved (hackster)'
            collection.approve! if collection.can_approve?
          elsif project.approved == false
            puts platform.name + ': rejected (hackster)'
            collection.reject! if collection.can_reject?
          else
            puts platform.name + ': waiting (hackster)'
          end
        when 'manual'
          puts platform.name + ': waiting (manual)'
          # do nothing
        end
      end
    end

    # record.platforms = Platform.joins(:platform_tags).references(:tags).where("LOWER(tags.name) IN (?)", record.platform_tags_cached.map{|t| t.strip.downcase }) if record.public? and !record.hide or (record.external and record.approved != false)
  end
end