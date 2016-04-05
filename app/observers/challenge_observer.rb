class ChallengeObserver < ActiveRecord::Observer
  def after_update record
    if record.activate_banners_changed? and record.open_for_submissions?
      record.sponsors.each do |platform|
        platform.active_challenge = record.display_banners?
        platform.save if platform.active_challenge_changed?
      end
    end

    # expire or purge only once
    keys = []
    purge = false
    if (record.changed & %w(slug)).any?
      keys << "challenge-index"
      purge = true
    end
    if (record.changed & %w(name custom_status idea_survey_link enter_button_text end_date start_date activate_pre_registration activate_pre_contest pre_contest_end_date pre_contest_start_date pre_registration_start_date custom_tweet winners_announced_date pre_winners_announced_date ready free_hardware_label free_hardware_quantity free_hardware_link free_hardware_end_date winners_label)).any?
      keys << "challenge-#{record.id}-status"
      purge = true
    end
    if (record.changed & %w(end_date start_date activate_pre_registration activate_pre_contest pre_contest_end_date pre_contest_start_date pre_registration_start_date pre_winners_announced_date winners_announced_date disabled_pre_contest_winners pre_contest_label disable_projects_phase free_hardware_end_date winners_label)).any?
      keys += ["challenge-#{record.id}-timeline", "challenge-#{record.id}-faq"]
      purge = true
    end
    if (record.changed & %w(video_link description rules)).any?
      keys << "challenge-#{record.id}-brief"
      purge = true
    end
    if (record.changed & %w(eligibility requirements judging_criteria how_to_enter)).any?
      keys += ["challenge-#{record.id}-brief", "challenge-#{record.id}-faq"]
      purge = true
    end
    if (record.changed & %w(name teaser slug)).any?
      keys << "challenge-#{record.id}-meta"
      purge = true
    end
    if (record.changed & %w(name teaser sponsor_name)).any?
      keys << "challenge-#{record.id}-banner"
      purge = true
    end
    if record.password_protect_changed? or record.disable_projects_tab_changed? or record.disable_participants_tab?
      purge = true
    end
    (record.changed & Challenge::TOKENABLE_ATTRIBUTES).each do |attr|
      keys << "challenge-#{record.id}-#{attr}"
      purge = true
    end
    Cashier.expire *keys if keys.any?
    FastlyWorker.perform_async 'purge', record.record_key if purge

    if (record.changed & %w(mailchimp_api_key mailchimp_list_id activate_mailchimp_sync)).any? and record.mailchimp_setup?
      MailchimpWorker.perform_in 5.seconds, 'sync_challenge', record.id
    end
    if record.pre_contest_awarded_changed? and record.pre_contest_awarded?
      ChallengeWorker.perform_async 'announce_pre_contest_winners', record.id
    end
  end

  def after_pre_launch record
    NotificationCenter.notify_via_email :pre_launched, :challenge, record.id
    display_banners record
    expire_cache record
    expire_index
  end

  # def after_launch_pre_contest record
  #   NotificationCenter.notify_all :launched_pre_contest, :challenge, record.id
  #   display_banners record
  #   expire_cache record
  #   expire_index
  # end

  # def after_end_pre_contest record
  #   NotificationCenter.notify_via_email :ended_pre_contest, :challenge, record.id
  #   expire_cache record
  # end

  # alias_method :after_end_pre_contest_fully, :after_end_pre_contest

  def after_launch_contest record
    NotificationCenter.notify_all :launched_contest, :challenge, record.id
    display_banners record
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
    ChallengeWorker.perform_async 'do_after_end', record.id
  end

  def after_mark_as_judged record
    ChallengeWorker.perform_async 'do_after_judged', record.id
  end

  def before_save record
    # parse all text fields that may contain tokens and cache which *recognized*
    # tokens they contain
    token_tags = record.token_tags.try(:dup) || {}
    (record.changed & Challenge::TOKEN_PARSABLE_ATTRIBUTES).each do |attr|
      parser = TokenParser.new record, record.send(attr)
      token_tags[attr] = (parser.all_cleaned & Challenge::TOKENABLE_ATTRIBUTES)
    end
    record.token_tags = token_tags
  end

  alias_method :after_cancel, :after_take_offline
  alias_method :after_reinitialize, :after_take_offline

  private
    def display_banners record
      if record.display_banners?
        record.sponsors.each do |platform|
          unless platform.active_challenge
            platform.active_challenge = true
            platform.save
          end
        end
      end
    end

    def disable_challenge_on_platform record
      record.sponsors.each do |platform|
        platform.active_challenge = false
        platform.save
      end
    end

    def expire_cache record
      Cashier.expire "challenge-#{record.id}-projects", "challenge-#{record.id}-status", "challenge-#{record.id}-timeline"
      FastlyWorker.perform_async 'purge', record.record_key
    end

    def expire_index
      Cashier.expire 'challenge-index'
    end
end