module ChallengeHelper
  def class_for_timeline dates, i
    this_date = dates[i][:date]
    next_date = dates[i + 1].try(:[], :date)
    if this_date < Time.now
      if !next_date or next_date > Time.now
        'highlight-date'
      else
        'mute-date'
      end
    end
  end
end