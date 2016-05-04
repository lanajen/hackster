class ChallengeDecorator < ApplicationDecorator
  def alternate_name
    model.alternate_name.presence || model.name
  end

  def bg_class
    if model.cover_image and model.cover_image.file_url
      'user-bg'
    else
      'default-bg'
    end
  end

  def cover_image size=:cover
    if model.cover_image and model.cover_image.file_url
      model.cover_image.imgix_url(size)
    else
      h.asset_url 'footer-bg.png'
    end
  end

  def alternate_cover_image size=:cover
    if model.alternate_cover_image and model.alternate_cover_image.file_url
      model.alternate_cover_image.imgix_url(size)
    else
      cover_image size
    end
  end

  def default_tweet
    append = if prize = model.prizes.first and prize.name.present?
      ' ' + h.indefinite_articlerize(prize.try(:name))
    end

    "Check out #{model.name}"
  end

  def prizes_count
    model.prizes.sum(:quantity)
  end

  def status
    return model.custom_status if model.custom_status.present?

    case model.workflow_state.to_sym
    when :new
      if model.ready
        date = if model.activate_pre_registration
          "#{l model.pre_registration_start_date.in_time_zone(PDT_TIME_ZONE), format: :long_date_time} PT"
        elsif model.activate_pre_contest
          "#{l model.pre_contest_start_date.in_time_zone(PDT_TIME_ZONE), format: :long_date_time} PT"
        else
          "#{l model.start_date.in_time_zone(PDT_TIME_ZONE), format: :long_date_time} PT"
        end
        "Launch scheduled for #{date}"
      else
        "Please mark the challenge as 'ready to launch' when ready."
      end
    when :pre_contest_in_progress
      "#{model.pre_contest_label} in progress"
    when :pre_contest_ended
      "#{model.pre_contest_label} ended"
    when :in_progress
      "#{time_left} left to enter"
    when :judging
      model.voting_active? ? 'Voting in progress' : 'Judging in progress'
    when :judged
      h.content_tag(:i, '', class: 'fa fa-check') + ' Prizes awarded'
    when :canceled
      'Canceled'
    end
  end

  def time_left
    h.time_diff_in_natural_language(Time.now, model.end_date)
  end

  def top_prize
    if prize = model.prizes.first
      if prize.description
        prize.description
      elsif prize.cash_value
        h.number_to_currency prize.cash_value, precision: 0
      end
    end
  end

  def to_tweet
    return model.custom_tweet if model.custom_tweet.present?

    default_tweet
  end

  def voting_time_left
    h.time_diff_in_natural_language(Time.now, model.voting_end_date)
  end
end