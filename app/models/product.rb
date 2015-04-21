class Product < ExternalProject
  def platform
    platforms.first
  end

  def user_name_for_url
    platform.try(:user_name) || 'someone'
  end
end