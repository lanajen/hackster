class BaseArticleObserver < ActiveRecord::Observer
  def after_create record
    update_counters record, :projects
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
  end

  def after_destroy record
    update_counters record, [:projects, :live_projects]
    record.team.destroy if record.team
    record.purge
  end

  def after_update record
    if record.private_changed?
      update_counters record, [:live_projects]
      record.commenters.each{|u| u.update_counters only: [:comments] }
      keys = []
      record.users.each { |u| keys << "user-#{u.id}" }
      Cashier.expire *keys
      record.users.each { |u| u.purge }
    end
    record.purge
  end

  def after_approved record
    ProjectWorker.perform_async 'update_platforms', record.id

    if record.made_public_at.nil?
      record.post_new_tweet! if record.should_tweet?
      record.made_public_at = Time.now
    elsif record.made_public_at > Time.now
      record.post_new_tweet_at! record.made_public_at if record.should_tweet?
    end

    # actions common to both statements above
    if record.made_public_at.nil? or record.made_public_at > Time.now
      record.save
      NotificationCenter.notify_all :approved, :base_article, record.id
    end

    record.users.each{|u| u.update_counters only: [:approved_projects] }
  end

  def after_rejected record
    record.update_column :hide, true
    record.users.each{|u| u.update_counters only: [:approved_projects] }
  end

  # def after_pending_review record
  #   record.update_column :private, false
  # end

  def before_create record
    record.reset_counters assign_only: true
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
        if record.force_hide?
          record.reject! if record.can_reject?
        else
          record.mark_needs_review! if record.can_mark_needs_review?
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

    if (record.changed & %w(name guest_name cover_image one_liner private wip start_date slug respects_count comments_count workflow_state content_type)).any?
      Cashier.expire "project-#{record.id}-thumb"
    end

    if (record.changed & %w(name guest_name cover_image one_liner slug)).any? or record.platform_tags_string_changed? or record.product_tags_string_changed?
      Cashier.expire "project-#{record.id}-meta-tags"
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