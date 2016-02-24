class ProjectWorker < BaseWorker
  sidekiq_options unique: :all, queue: :critical

  def create_review_event project_id, user_id=0, event_type='', meta={}
    thread = ReviewThread.where(project_id: project_id).first_or_create

    event = thread.events.new
    event.user_id = user_id
    event.event = event_type
    case event_type.to_sym
    when :project_privacy_update
      event.new_project_privacy = meta['privacy']
    when :project_status_update
      event.new_project_workflow_state = meta['workflow_state']
    when :project_updated
      event.project_changed_fields = meta['changed']
      thread.update_column :workflow_state, :project_updated
    when :thread_closed
    end
    event.save
  end

  def update_platforms id
    return unless project = BaseArticle.find_by_id(id)

    if project.pryvate?
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