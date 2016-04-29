class LiveEventDecorator < GeographicCommunityDecorator
  def cal_start_date
    model.start_date.strftime('%Y%m%dT%H%M00Z')
  end

  def cal_end_date
    model.end_date.strftime('%Y%m%dT%H%M00Z')
  end

  def date_range
    if model.start_date.present? and model.end_date.present?
      date = if model.start_date.month == model.end_date.month
        if model.start_date.day == model.end_date.day
          model.start_date.strftime('%B') + ' ' + model.start_date.day.ordinalize
        else
          model.start_date.strftime('%B') + ' ' + model.start_date.day.ordinalize + ' - ' + model.end_date.day.ordinalize
        end
      else
        model.start_date.strftime('%B') + ' ' + model.start_date.day.ordinalize + ' - ' + model.end_date.strftime('%B') + ' ' +  model.end_date.day.ordinalize
      end
      date += ', ' + model.start_date.year.to_s
      date
    else
      'no date set'
    end
  end

  def venue_address
    model.full_street_address
  end

  def status
    if model.in_the_future?
      'Upcoming'
    elsif model.end_date and model.end_date > Time.now
      'Happening now'
    else
      'Ended'
    end
  end
end