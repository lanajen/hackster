class ChallengeDecorator < ApplicationDecorator
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
    case model.workflow_state.to_sym
    when :new
      'Ready to launch'
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
      if prize.cash_value
        h.number_to_currency prize.cash_value, precision: 0
      else
        prize.description
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