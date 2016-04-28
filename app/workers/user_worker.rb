class UserWorker < BaseWorker
  sidekiq_options unique: :all, queue: :low, retry: false

  def update_last_seen user_id, time
    seen_at = Time.at time
    User.find(user_id).update_last_seen! seen_at
  end
end