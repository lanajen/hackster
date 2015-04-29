class UserObserver < ActiveRecord::Observer
  def after_commit_on_create record
    unless record.invited_to_sign_up? or record.reputation  # this callback seems to be called twice somehow, which means two sets of emails are sent. Checking on reputation to see if the callback has already been called.
      record.create_reputation
      advertise_new_user record unless record.simplified_signup?
      record.send_confirmation_instructions unless record.invitation_accepted?
    end
  end

  def after_destroy record
    Broadcast.where(context_model_id: record.id, context_model_type: 'User').destroy_all
    Broadcast.where(broadcastable_id: record.id, broadcastable_type: 'User').destroy_all
    Broadcast.where(user_id: record.id).destroy_all
    record.purge
  end

  def after_invitation_accepted record
    advertise_new_user record
    NotificationCenter.notify_all :accepted, :invitation, record.id
    record.build_reputation unless record.reputation
    record.update_column :invitation_token, nil if record.invitation_token.present?
    record.subscribe_to_all && record.save

    invite = record.find_invite_request
    if invite and project = invite.project
      team = project.team || project.build_team
      team.members.new(user_id: record.id)
      team.save
    end

    record.events.each{|e| e.update_counters only: [:participants] }

    record.group_ties.invitation_not_accepted.each do |member|
      member.accept_invitation!
    end
  end

  def after_save record
    return unless record.user_name.present?
    record.build_slug unless record.slug
    slug = record.slug
    slug.value = record.user_name.downcase
    slug.save
  end

  def after_update record
    if record.user_name_changed?
      record.teams.each do |team|
        team.update_attribute :user_name, record.user_name if team.user_name == record.user_name_was
      end
    end
    record.purge
  end

  def before_update record
    if record.accepted_or_not_invited? and (record.changed & %w(user_name mini_resume city country full_name)).any?
      record.broadcast :update, record.id, 'User'
    end
    record.interest_tags_count = record.interest_tags_string.split(',').count
    record.skill_tags_count = record.skill_tags_string.split(',').count


    if (record.changed & %w(full_name user_name avatar slug)).any?
      keys = ["user-#{record.id}-teaser", "user-#{record.id}-thumb"]
      record.teams.each{|t| keys << "team-#{t.id}" }
      record.respected_projects.each{|p| keys << "project-#{p.id}-respects" }
      Cashier.expire *keys
    end

    if (record.changed & %w(full_name avatar mini_resume slug user_name forums_link documentation_link crowdfunding_link buy_link twitter_link facebook_link linked_in_link blog_link github_link website_link youtube_link google_plus_link city country state)).any? or record.interest_tags_string_changed? or record.skill_tags_string_changed?
      Cashier.expire "user-#{record.id}-sidebar"
    end
  end

  def before_create record
    record.reset_counters assign_only: true
  end

  private
    def advertise_new_user record
      send_zapier record.email
      record.broadcast :new, record.id, 'User'
      NotificationCenter.notify_via_email nil, :user, record.id, 'registration_confirmation' unless record.skip_registration_confirmation
    end

    def expire record
    end

    def send_zapier email
      # between 8am and 8pm in the next 3 to 7 days
      time = Time.at(DateTime.tomorrow.in_time_zone(PDT_TIME_ZONE).to_time.to_i + 3.days.to_i + rand(0..4).days.to_i + rand(8.to_f..20.to_f).hours.to_f)
      ZapierQueue.perform_at time, 'post', email
    end
end