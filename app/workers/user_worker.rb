class UserWorker < BaseWorker
  sidekiq_options unique: :all, queue: :low, retry: false

  def revoke_api_tokens_for user_id
    Doorkeeper::AccessToken.where(resource_owner_id: user_id, revoked_at: nil).map(&:revoke)
  end

  def update_last_seen user_id, time
    seen_at = Time.at time
    User.find(user_id).update_last_seen! seen_at
  end
end