class ChallengeDecorator < ApplicationDecorator
  def cover_image
    model.cover_image.try(:file_url)
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
      'Prizes awarded'
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