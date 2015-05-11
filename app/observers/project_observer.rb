class ProjectObserver < ActiveRecord::Observer
  def after_create record
    update_counters record, :projects
  end

  def after_commit_on_create record
    if record.product?
      ProjectWorker.perform_async 'update_platforms', record.id
    end
  end

  def after_commit_on_update record
    if record.needs_platform_refresh
      ProjectWorker.perform_async 'update_platforms', record.id
    end

    if record.private_changed
      record.parts.each do |part|
        part.update_counters only: [:projects]
      end
    end

    if record.workflow_state_changed? and record.approved? and record.made_public_at
      NotificationCenter.notify_all :approved, :project, record.id
    end
  end

  def after_destroy record
    Broadcast.where(context_model_id: record.id, context_model_type: 'Project').destroy_all
    Broadcast.where(project_id: record.id).destroy_all
    update_counters record, [:projects, :live_projects]
    record.team.destroy if record.team
    record.purge
  end

  def after_save record
    if record.external? or record.product?
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
        Broadcast.where(project_id: record.id).destroy_all
      end
      keys = []
      record.users.each { |u| keys << "user-#{u.id}" }
      Cashier.expire *keys
      record.users.each { |u| u.purge }
    end
    record.purge
  end

  def after_status_updated record
    ProjectWorker.perform_async 'update_platforms', record.id

    if record.made_public_at.nil?
      record.post_new_tweet! unless record.hidden? or Rails.env != 'production'
      record.made_public_at = Time.now
      record.save
    elsif record.made_public_at > Time.now
      record.post_new_tweet_at! record.made_public_at unless record.hidden? or Rails.env != 'production'
    end
  end

  def before_create record
    record.reset_counters assign_only: true
    record.private_issues = record.private_logs = !!!record.open_source
    record.made_public_at = record.created_at if record.external? or record.product?
    record.last_edited_at = record.created_at
  end

  def before_update record
    if (record.changed & %w(private workflow_state platform_tags_string)).any?
      record.needs_platform_refresh = true
    end

    if record.private_changed?
      record.private_changed = true
      if record.private?
      else
        record.workflow_state = :rejected if record.pending_review? and record.force_hide?
      end
    end

    if record.workflow_state_changed?
      if record.rejected?
        record.hide = true
      elsif record.approved?
        record.approved_changed = true
        if record.made_public_at.nil?
          record.post_new_tweet! unless record.hidden? or Rails.env != 'production'
          record.made_public_at = Time.now
        elsif record.made_public_at > Time.now
          record.post_new_tweet_at! record.made_public_at unless record.hidden? or Rails.env != 'production'
        end
      end
    end

    if (record.changed & %w(name cover_image one_liner platform_tags product_tags made_public_at license private workflow_state featured featured_date respects_count comments_count)).any? or record.platform_tags_string_changed? or record.product_tags_string_changed?
      Cashier.expire "project-#{record.id}-teaser"
    end

    # if (record.changed & %w(platform_tags)).any? or record.platform_tags_string_changed? or record.product_tags_string_changed?
    #   Cashier.expire "project-#{record.id}-metadata"
    # end

    if record.description_changed?
      Cashier.expire "project-#{record.id}-widgets"
    end

    if (record.changed & %w(name guest_name cover_image one_liner private wip start_date slug respects_count comments_count workflow_state)).any?
      Cashier.expire "project-#{record.id}-thumb"
    end

    if (record.changed & %w(name guest_name cover_image one_liner slug)).any? or record.platform_tags_string_changed? or record.product_tags_string_changed?
      Cashier.expire "project-#{record.id}-meta-tags"
    end

    if record.external? or record.product? and (record.changed & %w(website)).any?
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