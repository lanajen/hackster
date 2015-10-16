class ProjectWorker < BaseWorker
  sidekiq_options unique: :all, queue: :critical

  def update_platforms id
    return unless project = BaseArticle.find_by_id(id)

    if project.private?
      project.platforms.delete_all
    else
      # merge platform_tags (for back compatibility) and platforms from parts
      platforms = Platform.joins(:platform_tags).references(:tags).where("LOWER(tags.name) IN (?)", project.platform_tags_cached.map{|t| t.downcase }).uniq
      platforms += project.part_platforms.default_scope
      project.platforms = platforms.uniq

      project.sub_platforms.each do |sub_platform|
        project.platforms << sub_platform unless sub_platform.in? platforms
      end

      project.project_collections.joins("INNER JOIN groups ON groups.id = project_collections.collectable_id AND project_collections.collectable_type = 'Group'").where(groups: { type: 'Platform'}).each do |collection|

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
    end
  end
end