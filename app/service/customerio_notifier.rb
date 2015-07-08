class CustomerioNotifier
  def initialize platform, user
    @platform = platform
    @user = user
  end

  def notify
    client.identify(
      id: @user.id,
      email: @user.email,
      created_at: Time.now.to_i,
      full_name: @user.name,
      platform_id: @platform.id,
      platform_name: @platform.name,
      platform_user_name: @platform.user_name,
    )
    # client.track(5, "purchase", type: "socks", price: "13.99")
  end

  private
    def client
      @client ||= Customerio::Client.new(ENV['CUSTOMERIO_SITE_ID'], ENV['CUSTOMERIO_API_KEY'])
    end
end