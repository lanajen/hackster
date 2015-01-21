class ProjectObserver < ActiveRecord::Observer
  def after_create record
    update_counters record, :projects
  end

  def after_destroy record
    Broadcast.where(context_model_id: record.id, context_model_type: 'Project').destroy_all
    Broadcast.where(project_id: record.id).destroy_all
    update_counters record, [:projects, :live_projects]
    record.team.destroy if record.team
  end

  def after_save record
    if record.external
      record.slug_histories.destroy_all
    else
      SlugHistory.update_history_for record.id if record.slug_changed? or (record.guest_name.present? and record.guest_name_changed?)
    end
  end

  def after_update record
    if record.private_changed?
      update_counters record, [:live_projects]
      record.commenters.each{|u| u.update_counters only: [:comments] }
      if record.private?
        Broadcast.where(context_model_id: record.id, context_model_type: 'Project').destroy_all
      end
    end

    if (record.changed && %w(private approved platform_tags_string)).any?
      ProjectWorker.perform_async 'update_platforms', record.id
    end

    # if record.approved_changed? and record.approved
    #   record.project_collections.each{|g| g.approve! }
    # end
  end

  def before_create record
    record.reset_counters assign_only: true
    record.private_issues = record.private_logs = !!!record.open_source
    record.made_public_at = record.created_at if record.external
    record.last_edited_at = record.created_at
  end

  def before_save record
    # record.platforms = Platform.joins(:platform_tags).references(:tags).where("LOWER(tags.name) IN (?)", record.platform_tags_cached.map{|t| t.strip.downcase }) if record.public? and !record.hide or (record.external and record.approved != false)

    # ProjectQueue.perform_async 'update_platforms', record.id
    # three approval levels after projects made public:
    # - auto approve all
    # mark pj approved immediately
    # - hackster approves
    # mark as pending_approval immediately, mark pj approved/rejected based on full project approval
    # - platform approves
    # mark as pending_approval immediately



    # if record.private_changed? and record.public?
      # record.post_new_tweet! unless record.made_public_at.present? or record.disable_tweeting? or Rails.env != 'production'
      # record.made_public_at = Time.now
    # end
  end

  def before_update record
    if record.private_changed?
      update_counters record, [:live_projects]
      record.commenters.each{|u| u.update_counters only: [:comments] }
      if record.private?
        Broadcast.where(context_model_id: record.id, context_model_type: 'Project').destroy_all
        Broadcast.where(project_id: record.id).destroy_all
      else
        record.hide = true if record.force_hide?
      end
    end

    if record.approved_changed?
      if record.approved == false
        record.hide = true
      elsif record.approved == true and record.made_public_at.nil?
        record.post_new_tweet! unless record.hidden? or Rails.env != 'production'
        record.made_public_at = Time.now
      end
    end

    if (record.changed & %w(name cover_image one_liner platform_tags product_tags made_public_at license private workflow_state featured featured_date respects_count comments_count)).any? or record.platform_tags_string_changed? or record.product_tags_string_changed?
      Cashier.expire "project-#{record.id}-teaser"
    end

    # if (record.changed & %w(name cover_image one_liner platform_tags product_tags guest_name )).any? or record.platform_tags_string_changed? or record.product_tags_string_changed?
    #   Cashier.expire "project-#{record.id}-meta-tags"
    # end

    if (record.changed & %w(platform_tags)).any? or record.platform_tags_string_changed? or record.product_tags_string_changed?
      Cashier.expire "project-#{record.id}-metadata"
    end

    if record.description_changed?
      Cashier.expire "project-#{record.id}-widgets"
    end

    if (record.changed & %w(name guest_name cover_image one_liner private wip start_date slug respects_count comments_count workflow_state)).any?
      Cashier.expire "project-#{record.id}-thumb"
    end

    if record.external and (record.changed & %w(website)).any?
      Cashier.expire "project-#{record.id}-thumb"
    end

    if (record.changed & %w(name cover_image one_liner private wip start_date made_public_at license buy_link description)).any? or record.platform_tags_string_changed? or record.product_tags_string_changed?
      record.last_edited_at = Time.now
    end
  end

  private
    def update_counters record, type
      record.users.each{ |u| u.update_counters only: [type].flatten }
    end
end