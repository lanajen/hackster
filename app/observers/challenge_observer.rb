class ChallengeObserver < ActiveRecord::Observer
  def after_update record
    if record.activate_banners_changed? and record.open_for_submissions? and platform = record.platform
      platform.active_challenge = record.display_banners?
      platform.save if platform.active_challenge_changed?
    end

    # expire or purge only once
    keys = []
    purge = false
    if (record.changed & %w(slug)).any?
      keys << "challenge-index"
      purge = true
    end
    if (record.changed & %w(name custom_status idea_survey_link enter_button_text end_date start_date activate_pre_registration activate_pre_contest pre_contest_end_date pre_contest_start_date pre_registration_start_date custom_tweet winners_announced_date pre_winners_announced_date ready)).any?
      keys << "challenge-#{record.id}-status"
      purge = true
    end
    if (record.changed & %w(end_date start_date activate_pre_registration activate_pre_contest pre_contest_end_date pre_contest_start_date pre_registration_start_date pre_winners_announced_date winners_announced_date)).any?
      keys << "challenge-#{record.id}-timeline"
      purge = true
    end
    if (record.changed & %w(video_link description eligibility requirements judging_criteria how_to_enter rules)).any?
      keys << "challenge-#{record.id}-brief"
      purge = true
    end
    if record.password_protect_changed? or record.disable_projects_tab_changed?
      purge = true
    end
    Cashier.expire *keys if keys.any?
    record.purge if purge

    if (record.changed & %w(mailchimp_api_key mailchimp_list_id activate_mailchimp_sync)).any? and record.mailchimp_setup?
      MailchimpWorker.perform_async 'sync_challenge', record.id
    end
  end

  def after_pre_launch record
    NotificationCenter.notify_via_email :pre_launched, :challenge, record.id
    expire_cache record
    expire_index
  end

  def after_launch_pre_contest record
    NotificationCenter.notify_all :launched_pre_contest, :challenge, record.id
    expire_cache record
    expire_index
  end

  def after_end_pre_contest record
    NotificationCenter.notify_via_email :ended_pre_contest, :challenge, record.id
    expire_cache record
  end

  def after_launch_contest record
    NotificationCenter.notify_all :launched_contest, :challenge, record.id
    if record.display_banners?
      platform = record.platform
      platform.active_challenge = true
      platform.save
    end
    expire_cache record
    expire_index
  end

  def after_take_offline record
    disable_challenge_on_platform record
    expire_cache record
    expire_index
  end

  def after_end record
    NotificationCenter.notify_via_email :completed, :challenge, record.id
    disable_challenge_on_platform record
    expire_cache record
    expire_index
  end

  def after_mark_as_judged record
    ChallengeWorker.perform_async 'do_after_judged', record.id
  end

  alias_method :after_cancel, :after_take_offline
  alias_method :after_reinitialize, :after_take_offline

  private
    def disable_challenge_on_platform record
      if platform = record.platform
        platform.active_challenge = false
        platform.save
      end
    end

    def expire_cache record
      Cashier.expire "challenge-#{record.id}-projects", "challenge-#{record.id}-status", "challenge-#{record.id}-timeline"
      record.purge
    end

    def expire_index
      Cashier.expire 'challenge-index'
    end
end