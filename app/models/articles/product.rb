class Product < BaseProject
  PUBLIC_CONTENT_TYPES = {
    'Product' => :product,
  }

  def platform
    platforms.first
  end

  def user_name_for_url
    platform.try(:user_name) || 'someone'
  end
end