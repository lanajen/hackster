class CriticalCronWorker < BaseWorker
  sidekiq_options queue: :critical, retry: 0

  def update_challenges_workflow
    Challenge.ready.where(workflow_state: :new).where("CAST(challenges.hproperties -> 'activate_pre_registration' AS BOOLEAN) = ?", true).where("CAST(challenges.hproperties -> 'pre_registration_start_date' AS INTEGER) < ?", Time.now.to_i).each do |challenge|
      challenge.pre_launch!
    end
    Challenge.ready.where(workflow_state: %w(new pre_registration)).where("CAST(challenges.hproperties -> 'activate_pre_contest' AS BOOLEAN) = ?", true).where("CAST(challenges.hproperties -> 'pre_contest_start_date' AS INTEGER) < ?", Time.now.to_i).each do |challenge|
      challenge.launch_pre_contest!
    end
    Challenge.where(workflow_state: :pre_contest_in_progress).where("CAST(challenges.hproperties -> 'pre_contest_end_date' AS INTEGER) < ?", Time.now.to_i).each do |challenge|
      challenge.disable_projects_phase? ? challenge.end_pre_contest_fully! : challenge.end_pre_contest!
    end
    Challenge.ready.where(workflow_state: %w(new pre_registration pre_contest_ended)).where("challenges.start_date < ?", Time.now).each do |challenge|
      challenge.launch_contest!
    end
    Challenge.where(workflow_state: :in_progress).where("challenges.end_date < ?", Time.now).each do |challenge|
      challenge.end!
    end
  end

  def launch_cron
    CriticalCronWorker.perform_async 'update_challenges_workflow'
  end
end