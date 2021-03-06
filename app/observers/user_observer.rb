class UserObserver < ActiveRecord::Observer
  def after_commit_on_create record
    unless record.reputation  # this callback seems to be called twice somehow, which means two sets of emails are sent. Checking on reputation to see if the callback has already been called.
      record.create_reputation
      unless record.invited_to_sign_up?
        advertise_new_user record unless record.simplified_signup?
        record.send_confirmation_instructions unless record.invitation_accepted? or record.skip_email_confirmation
        if record.skip_email_confirmation
          record.confirm!
        end
      end
    end
  end

  def after_destroy record
    FastlyWorker.perform_async 'purge', record.record_key

    record.comments.update_all(user_id: -1)
  end

  def after_invitation_accepted record
    advertise_new_user record
    NotificationCenter.perform_in 15.minutes, 'notify_all', :accepted, :invitation, record.id
    record.create_reputation unless record.reputation
    record.update_column :invitation_token, nil if record.invitation_token.present?
    record.set_notification_preferences && record.save

    record.events.each{|e| e.update_counters only: [:participants] }

    record.group_ties.invitation_not_accepted.each do |member|
      member.accept_invitation!
    end
  end

  def after_save record
    if record.user_name_changed? and record.user_name.present?
      record.build_slug unless record.slug
      slug = record.slug
      slug.value = record.user_name.downcase
      slug.save
    end
  end

  def after_update record
    if record.user_name_changed?
      record.teams.each do |team|
        team.update_attribute :user_name, record.user_name if team.user_name == record.user_name_was
      end
    end

    # the unless condition is a hack to not trigger a purge when we're just updating the last_sent_projects_email_at prop
    FastlyWorker.perform_async 'purge', record.record_key unless record.changed == ['last_sent_projects_email_at', 'properties', 'updated_at']

    if record.encrypted_password_changed?
      NotificationCenter.notify_via_email nil, :user, record.id, 'password_changed_confirmation'
    end
  end

  def before_update record
    record.interest_tags_count = record.interest_tags_cached.count
    record.skill_tags_count = record.skill_tags_cached.count

    keys = []

    if (record.changed & %w(projects_count followers_count)).any?
      keys << "user-#{record.id}-thumb"
      record.teams.each{|t| keys << "team-#{t.id}" }
    end

    if (record.changed & %w(full_name user_name avatar slug)).any?
      keys << "user-#{record.id}-thumb"
      record.teams.each{|t| keys << "team-#{t.id}" }
      record.lists.each{|l| keys << "list-#{l.id}-thumb"}
      record.respected_projects.each{|p| keys << "project-#{p.id}-respects" }
    end

    if (record.changed & %w(full_name avatar mini_resume slug user_name forums_link documentation_link crowdfunding_link buy_link twitter_link facebook_link linked_in_link blog_link github_link website_link youtube_link google_plus_link city country state projects_count followers_count reputation_count available_for_ft available_for_pt available_for_hire)).any? or record.interest_tags_string_changed? or record.skill_tags_string_changed?
      keys << "user-#{record.id}-sidebar"
    end

    if (record.changed & %w(reputation_count)).any?
      record.reputation.try(:compute_redeemable!)
    end

    # cleanup when an invited user signs up from a different path
    if record.invitation_token and record.encrypted_password_changed?
      record.invitation_token = nil
      record.invitation_accepted_at = Time.now if record.invitation_accepted_at.nil?
      record.generate_user_name if record.user_name.blank? and record.new_user_name.blank?
      record.build_reputation unless record.reputation
      record.set_notification_preferences
      advertise_new_user record
    end

    Cashier.expire *keys if keys.any?
  end

  def before_create record
    record.reset_counters assign_only: true
    if record.platform.present? and record.platform != 'hackster' and platform = Platform.find_by_user_name(record.platform)
      record.followed_platforms << platform
    end
  end

  private
    def advertise_new_user record
      NotificationCenter.notify_via_email nil, :user, record.id, 'registration_confirmation' unless record.skip_welcome_email
    end

    def expire record
    end
end