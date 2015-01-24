class GroupDecorator < UserDecorator
  def avatar size=:thumb
    if model.avatar and model.avatar.file_url
      model.avatar.file_url(size)
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
      model.cover_image.file_url(size)
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
    "//gravatar.com/avatar/#{gravatar_id}.png?d=identicon&s=#{width}"
  end

  def twitter_share
    case model.type
    when 'List'
      if model.category?
        "Check out all the #{model.name} hacks on @hacksterio."
      else
        "Check out all the hacks curated by #{model.name}#{' (' + model.twitter_handle + ')' if model.twitter_handle}."
      end
    when 'Platform'
      "Check out all the hacks made with #{model.name}#{' (' + model.twitter_handle + ')' if model.twitter_handle}."
    end
  end
end