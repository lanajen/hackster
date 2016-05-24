class ReputationWorker < BaseWorker
  sidekiq_options queue: :cron, retry: 3

  def compute_reputation user_id
    Rewardino::Event.compute_for_user user_id

    user = User.find user_id
    user.update_counters only: [:new_project_views, :reputation]
    user.build_reputation unless user.reputation
    user.reputation.compute_redeemable!
    user.update_attribute :reputation_last_updated_at, Time.now
  end

  def compute_daily_reputation
    time = Time.now  # throttle updates to give the DB more breathing room
    User.invitation_accepted_or_not_invited.not_hackster.find_each do |user|
      self.class.perform_at time, 'compute_reputation', user.id
      time += (1.second.to_f / 10)  # 10 per second =~ 10 minutes to compute 70k records
    end
  end
end