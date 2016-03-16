class ChallengeIdeaDecorator < ApplicationDecorator
  def image size=:thumb
    if model.image and model.image.file_url
      model.image.imgix_url(size)
    else
      h.asset_url "project_default_large_image.png"
    end
  end

  def image_tag size=:thumb
    if image(size)
      h.image_tag image(size)
    end
  end

  def status
    case model.workflow_state.to_sym
    when :new
      'Awaiting review'
    when :approved
      model.challenge.activate_pre_contest? ? 'Approved' : "You're getting free hardware!"
    when :rejected
      model.challenge.activate_pre_contest? ? 'Rejected' : "Sorry, your idea was not selected."
    when :won
      model.challenge.pre_contest_awarded? ? 'Won!' : 'Approved'
    when :lost
      model.challenge.pre_contest_awarded? ? 'Did not win. Next time!' : 'Approved'
    when :fulfilled
      'Prize sent'
    end
  end
end