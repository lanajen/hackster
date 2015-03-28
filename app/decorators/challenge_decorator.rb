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
      model.cover_image.file_url(size)
    else
      h.asset_url 'footer-bg.png'
    end
  end

  def default_tweet
    append = if prize = model.prizes.first and prize.name.present?
      ' ' + h.indefinite_articlerize(prize.try(:name))
    end

    "Submit your project to #{model.name} and win#{append}."
  end

  def status
    case model.workflow_state.to_sym
    when :new
      'Ready to launch'
    when :in_progress
      "#{time_left} left to enter"
    when :judging
      'Judging in progress'
    when :judged
      h.content_tag(:i, '', class: 'fa fa-check') + ' Prizes awarded'
    end
  end

  def time_left
    h.time_diff_in_natural_language(Time.now, model.end_date)
  end

  def to_tweet
    return model.custom_tweet if model.custom_tweet.present?

    default_tweet
  end
end