class Product < ExternalProject
  is_impressionable counter_cache: true, unique: :session_hash

  def platform
    platforms.first
  end

  def user_name_for_url
    platform.try(:user_name) || 'someone'
  end
end