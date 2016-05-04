class UserCriticalWorker < BaseWorker
  sidekiq_options unique: :all, queue: :critical

  def destroy user_id
    User.find(user_id).destroy_now
  end
end