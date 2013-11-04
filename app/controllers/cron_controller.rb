class CronController < ActionController::Base
  def run
    Resque.enqueue CronTask, 'launch_cron'
    render text: 'Cron scheduled.', status: :ok
  end
end