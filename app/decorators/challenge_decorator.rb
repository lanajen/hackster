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

  private
    def raw_text_to_html text
      text.gsub!("\r\n", '<br>')
      text = '<p>' + text.split('<br><br>').join('</p><p>') + '</p>'
      text.html_safe
    end
end