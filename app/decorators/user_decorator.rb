class UserDecorator < ApplicationDecorator
  def avatar size=:thumb
    if model.avatar and model.avatar.file_url
      avatar = model.avatar.imgix_url(size)
    else
      avatar = gravatar size
    end
    avatar
  end

  def avatar_link size=:thumb
    link_to_model h.image_tag(avatar(size), alt: model.name)
  end

  def name_link
    model.name
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
    gravatar_id = Digest::MD5::hexdigest(model.email).downcase
    "//gravatar.com/avatar/#{gravatar_id}.png?d=retro&s=#{width}"
  end

  def location
    if model.city.present? and model.country.present?
      "#{model.city}, #{model.country}"
    elsif model.city.present?
      model.city
    elsif model.country.present?
      model.country
    else
      false
    end
  end

  def name_link
    link_to_model model.name
  end
end