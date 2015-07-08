class CustomerioNotifierWorker < BaseWorker
  def notify platform_id, user_id
    platform = Platform.find_by_id platform_id
    user = User.find_by_id user_id
    return unless platform and user

    CustomerioNotifier.new(platform, user).notify
  end
end