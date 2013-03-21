class UserDecorator < ApplicationDecorator
  decorates :user

  def avatar size=:thumb
    if model.avatar
      avatar = model.avatar.file_url(size)
    else
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
      avatar = "//gravatar.com/avatar/#{gravatar_id}.png?d=identicon&s=#{width}"
    end
    avatar
  end

  def avatar_link size=:thumb
    link_to_user h.image_tag(avatar(size), alt: model.name)
  end

  def origin
    if model.city.present? and model.country.present?
      "#{model.city}, #{model.country}"
    elsif model.city.present?
      model.city
    elsif model.country.present?
      model.country
    else
      'somewhere in the world'
    end
  end

  def name_link
    link_to_user model.name
  end

  private
    def link_to_user content
      h.link_to content, h.user_profile_path(model.user_name)
    end
end