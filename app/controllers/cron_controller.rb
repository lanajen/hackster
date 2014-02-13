class CronController < ActionController::Base
  def run
    CronTask.perform_async 'launch_cron'
    render text: 'Cron scheduled.', status: :ok
  end
end