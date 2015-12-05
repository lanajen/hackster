class BaseArticleObserver < ActiveRecord::Observer
  def after_create record
    BaseArticleObserverWorker.perform_async 'after_create', record.id
  end

  def after_commit_on_update record
    BaseArticleObserverWorker.perform_async 'after_commit_on_update', record.id, record.needs_platform_refresh, record.private_changed
  end

  def after_destroy record
    BaseArticleObserverWorker.perform_async 'after_destroy', record.id
  end

  def after_update record
    BaseArticleObserverWorker.perform_async 'after_update', record.id, record.private_changed?
  end

  def after_approved record
    BaseArticleObserverWorker.perform_async 'after_approved', record.id
  end

  def after_rejected record
    BaseArticleObserverWorker.perform_async 'after_rejected', record.id
  end

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
      if record.pryvate?
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
end