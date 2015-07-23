class ActionDispatch::Request
  def ip
    @ip ||= @env['HTTP_FASTLY_CLIENT_IP'].presence || super
  end
end