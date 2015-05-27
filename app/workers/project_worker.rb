class ProjectWorker < BaseWorker
  sidekiq_options unique: :all, queue: :critical

  def update_platforms id
    return unless project = Project.find_by_id(id)

    if project.private?
      project.platforms.delete_all
    else
      platforms = project.platforms = Platform.joins(:platform_tags).references(:tags).where("LOWER(tags.name) IN (?)", project.platform_tags_cached.map{|t| t.downcase })

      project.sub_platforms.each do |sub_platform|
        project.platforms << sub_platform unless sub_platform.in? platforms
      end

      project.project_collections.joins("inner join groups on groups.id = project_collections.collectable_id and project_collections.collectable_type = 'Group'").where(groups: { type: 'Platform'}).each do |collection|

        platform = collection.collectable

        case platform.moderation_level
        when 'auto'
          collection.approve! if collection.can_approve?
        when 'hackster'
          if project.approved?
            collection.approve! if collection.can_approve?
          elsif project.rejected?
            collection.reject! if collection.can_reject?
          else
            # do nothing
          end
        when 'manual'
          # do nothing
        end
      end




      # existing_platforms = project.platforms

      # new_platforms = project.platform_tags_cached.map do |tag|
      #   next unless platform = Platform.joins(:platform_tags).references(:tags).where("LOWER(tags.name) = ?", tag.downcase).first

      #   collection = ProjectCollection.where(collectable_id: platform.id, collectable_type: 'Group', project_id: project.id).first_or_create

      #   case platform.moderation_level
      #   when 'auto'
      #     collection.approve! if collection.can_approve?
      #   when 'hackster'
      #     if project.approved?
      #       collection.approve! if collection.can_approve?
      #     elsif project.approved == false
      #       collection.reject! if collection.can_reject?
      #     else
      #       # do nothing
      #     end
      #   when 'manual'
      #     # do nothing
      #   end

      #   platform
      # end

      # (existing_platforms - new_platforms).each do |deleted|
      #   project.platforms.delete deleted
      # end
    end
  end
end