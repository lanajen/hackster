class BaseArticleObserver < ActiveRecord::Observer
  def after_create record
    BaseArticleObserverWorker.perform_async 'after_create', record.id
  end

  def after_commit_on_update record
    BaseArticleObserverWorker.perform_async 'after_commit_on_update', record.id, record.needs_platform_refresh, record.private_changed
  end

  def after_destroy record
    BaseArticleObserverWorker.new.after_destroy record  # synchronous
  end

  def after_update record
    BaseArticleObserverWorker.perform_async 'after_update', record.id, record.private_changed?, record.changed
  end

  def after_approved record
    BaseArticleObserverWorker.perform_in 1.second, 'after_approved', record.id
  end

  def after_pending_review record
    record.update_column :private, false if record.pryvate?
    BaseArticleObserverWorker.perform_async 'after_pending_review', record.id
  end

  def after_rejected record
    BaseArticleObserverWorker.perform_in 1.second, 'after_rejected', record.id
  end

  def before_create record
    record.reset_counters assign_only: true
    record.last_edited_at = record.created_at
  end

  def before_update record
    if record.changed? and record.updater_id
      ProjectWorker.perform_async 'create_review_event', record.id, record.updater_id, :project_update, changed: record.changed
    end

    if (record.changed & %w(private workflow_state platform_tags_string)).any?
      record.needs_platform_refresh = true
    end

    if record.private_changed?
      record.private_changed = true
      if record.pryvate?
        if !record.approved? and !record.rejected? and record.review_thread
          record.review_thread.update_column :workflow_state, :new
        end
      else
        if record.force_hide?
          record.reject! if record.can_reject?
        end
      end
    end

    if record.workflow_state_changed?
      record.create_review_thread unless record.review_thread
      new_state = nil

      case record.workflow_state
      when :pending_review, :needs_work
        if record.publyc?
          new_state = :needs_review
        else
          new_state = :new
        end
      when :approved, :rejected
        new_state = :closed
      end

      record.review_thread.update_column :workflow_state, new_state if record.review_thread and new_state
    end

    cache_keys = []

    if (record.changed & %w(name cover_image one_liner platform_tags product_tags made_public_at license private workflow_state featured featured_date respects_count comments_count)).any? or record.platform_tags_string_changed? or record.product_tags_string_changed?
      cache_keys << "project-#{record.id}-teaser"
    end

    # if (record.changed & %w(platform_tags)).any? or record.platform_tags_string_changed? or record.product_tags_string_changed?
    #   Cashier.expire "project-#{record.id}-metadata"
    # end

    if record.description_changed? or record.story_json_changed? or record.type_changed?
      record.extract_toc!
      cache_keys << "project-#{record.id}-widgets"
    end

    if (record.changed & %w(name guest_name cover_image one_liner private wip start_date slug respects_count comments_count workflow_state content_type)).any?
      cache_keys << "project-#{record.id}-thumb"
    end

    if (record.changed & %w(name guest_name cover_image one_liner slug)).any? or record.platform_tags_string_changed? or record.product_tags_string_changed?
      cache_keys << "project-#{record.id}-meta-tags"
    end

    if (record.changed & %w(name cover_image one_liner private wip start_date made_public_at license buy_link description)).any? or record.platform_tags_string_changed? or record.product_tags_string_changed?
      record.last_edited_at = Time.now
    end

    if (["project-#{record.id}-teaser", "project-#{record.id}-widgets"] & cache_keys).any?
      cache_keys << "project-#{record.id}-left-column"
      cache_keys << "project-#{record.id}"
    end

    Cashier.expire *cache_keys if cache_keys.any?
  end
end