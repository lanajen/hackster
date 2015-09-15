class GroupDecorator < UserDecorator
  def avatar size=:thumb
    if model.avatar and model.avatar.file_url
      model.avatar.imgix_url(size)
    end
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

  def gravatar size=:thumb
    width = case size
    when :tiny
      20
    when :mini
      40
    when :thumb
      60
    when :medium
      80
    when :big
      200
    end
    model.email ||= 'hi@hackster.io'  # TODO: find a better way
    gravatar_id = Digest::MD5::hexdigest(model.email).downcase
    "//gravatar.com/avatar/#{gravatar_id}.png?d=retro&s=#{width}"
  end

  def twitter_share
    message = case model.type
    when 'List'
      add_curated_by "Check out all the hardware projects in '#{model.name}'"
    when 'Platform'
      "Check out all the hardware projects made with #{model.name}"
    when 'Event', 'HackerSpace'
      "Check out all the hardware projects at #{model.name}"
    else
      "Check out all the hardware projects for #{model.name}"
    end
    message += " (#{model.twitter_handle})" if model.twitter_handle
    message += " on @hacksterio"
    message
  end

  def social_share
    message = case model.type
    when 'List'
      add_curated_by "Check out all the hardware projects in '#{model.name}'"
    when 'Platform'
      "Check out all the hardware projects made with #{model.name}"
    when 'Event', 'HackerSpace'
      "Check out all the hardware projects at #{model.name}"
    else
      "Check out all the hardware projects for #{model.name}"
    end
    message += " on Hackster.io"
    message
  end

  def to_share_message
    twitter_share
  end

  private
    def add_curated_by text
      text += ", curated by #{model.team_members.first.user.name}" if model.team_members_count > 0
      text
    end
end