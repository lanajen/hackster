class ReputationWorker < BaseWorker
  sidekiq_options queue: :cron, retry: 3

  def compute_reputation user_id
    Rewardino::Event.compute_for_user user_id

    user = User.find user_id
    user.update_counters only: [:reputation]
    user.build_reputation unless user.reputation
    user.reputation.compute_redeemable!
  end

  def compute_daily_reputation
    User.invitation_accepted_or_not_invited.find_each do |user|
      CronTask.perform_async 'compute_reputation', user.id
    end
  end
end