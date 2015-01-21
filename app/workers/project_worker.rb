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
          collection.approve! if collection.can_approve?
        when 'hackster'
          if project.approved?
            collection.approve! if collection.can_approve?
          elsif project.approved == false
            collection.reject! if collection.can_reject?
          else
            # do nothing
          end
        when 'manual'
          # do nothing
        end
      end
    end
  end
end