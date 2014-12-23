class ListObserver < ActiveRecord::Observer

  def before_create record
    record.update_counters assign_only: true
  end

  def before_update record
    if (record.changed & %w(cover_image)).any?
      Cashier.expire "list-#{record.id}-cover"
    end

    if (record.changed & %w(full_name avatar mini_resume slug user_name forums_link documentation_link crowdfunding_link buy_link twitter_link facebook_link linked_in_link blog_link github_link website_link youtube_link google_plus_link logo projects_count members_count)).any?
      Cashier.expire "list-#{record.id}-sidebar"
    end
  end
end