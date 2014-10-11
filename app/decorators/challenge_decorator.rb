class ChallengeDecorator < ApplicationDecorator
  def cover_image size=nil
    if model.cover_image and model.cover_image.file_url
      model.cover_image.file_url(size)
    end
  end

  def status
    case model.workflow_state.to_sym
    when :new
      'Ready to launch'
    when :in_progress
      "#{time_left} left to enter"
    when :judging
      'Submissions closed - Judging in progress'
    when :judged
      'Submissions closed - Prizes awarded'
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