class PlatformObserver < ActiveRecord::Observer
  def after_save record
    return unless record.user_name.present?
    record.build_slug unless record.slug
    slug = record.slug
    slug.value = record.user_name.downcase
    slug.save
  end

  def before_update record
    if (record.changed & %w(private hidden)).any?
      Cashier.expire 'platform-index'
    end

    if (record.changed & %w(full_name avatar mini_resume slug private_projects_count projects_count user_name)).any?
      Cashier.expire "platform-#{record.id}-thumb", "platform-#{record.id}-card", 'platform-index'
    end

    if (record.changed & %w(members_count)).any?
      Cashier.expire "platform-#{record.id}-card"
    end

    if (record.changed & %w(full_name project_ideas_phrasing cover_image)).any?
      Cashier.expire "platform-#{record.id}-submit-idea"
    end

    expire_index if record.private_changed?

    if (record.changed & %w(cover_image)).any?
      Cashier.expire "platform-#{record.id}-cover"
    end

    if (record.changed & %w(logo)).any?
      Cashier.expire "platform-#{record.id}-client-nav"
    end

    if (record.changed & %w(avatar full_name slug user_name)).any?
      keys = record.followers.map{|u| "user-#{u.id}-sidebar" }
      keys += record.members.map{|u| "user-#{u.id}-sidebar" }
      Cashier.expire *keys if keys.any?
    end

    if (record.changed & %w(full_name avatar mini_resume slug user_name forums_link documentation_link crowdfunding_link buy_link twitter_link facebook_link linked_in_link blog_link github_link website_link youtube_link google_plus_link logo projects_count members_count)).any?
      Cashier.expire "platform-#{record.id}-sidebar"
    end

    if (record.changed & %w(logo)).any?
      Cashier.expire "platform-#{record.id}-client-nav"
    end
  end

  def before_create record
    record.update_counters assign_only: true
  end

  def after_create record
    expire_index
  end

  def after_destroy record
    expire_index
  end

  private
    def expire_index
      Cashier.expire 'platform-index'
    end
end