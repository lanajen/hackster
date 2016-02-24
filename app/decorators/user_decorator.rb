class UserDecorator < ApplicationDecorator
  def avatar size=:thumb, opts={}
    if !opts[:disable_whitelabel] and is_whitelabel? and current_site.enable_custom_avatars?
      h.user_avatar_url(model.id, size: size, host: current_site.host)
    else
      if model.avatar and model.avatar.file_url
        model.avatar.imgix_url(size)
      else
        default_avatar size
      end
    end
  end

  def avatar_link size=:thumb
    link_to_model h.image_tag(avatar(size), alt: model.name)
  end

  def avatar_tag size=:thumb, opts={}
    h.image_tag avatar(size), opts.merge(alt: model.name)
  end

  def default_avatar size=:thumb
    if is_whitelabel? and current_site.has_default_avatar?
      h.current_site.default_avatar_url
    else
      gravatar size
    end
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

  def job_availability
    availability = []
    availability << 'full time' if model.available_for_ft
    availability << 'part time' if model.available_for_pt
    availability << 'contract' if model.available_for_hire

    if availability.any?
      h.content_tag(:p, "Available for #{availability.to_sentence} jobs.")
    end
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