class CustomAvatarHandler
  def add provider, avatar_url
    store[provider] = avatar_url
    @user.custom_avatar_urls = store
  end

  def fetch provider
    store[provider]
  end

  def initialize user
    @user = user
  end

  private
    def store
      @store ||= @user.custom_avatar_urls.try(:dup) || {}
    end
end