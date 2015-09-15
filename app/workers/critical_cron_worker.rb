class CriticalCronWorker < BaseWorker
  sidekiq_options queue: :critical, retry: 0

  def expire_challenges
    Challenge.where(workflow_state: :in_progress).where("challenges.end_date < ?", Time.now).each do |challenge|
      challenge.end!
    end
  end

  def launch_cron
    CriticalCronWorker.perform_async 'expire_challenges'
    CriticalCronWorker.perform_in 1.minute, 'launch_cron'
  end
end