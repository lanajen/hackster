# require 'heroku-api'

# module HerokuAutoScaleDown
#   # scaler extracted from heroku_auto_scale because we only want scaling down
#   module Scaler
#     class << self
#       @@heroku = Heroku::API.new(:api_key => ENV['HEROKU_API_KEY'],
#         :mock => (Rails.env == 'development'))

#       def workers=(qty)
#         @@heroku.post_ps_scale(ENV['HEROKU_APP'], 'worker', qty.to_s)
#       end

#       def job_count
#         Resque.info[:pending].to_i
#       end
#     end
#   end

#   def after_perform_scale_down(*args)
#     # Nothing fancy, just shut everything down if we have no jobs
#     Scaler.workers = 0 if Scaler.job_count.zero?
#   end
# end

class TrackerQueue < BaseWorker
  sidekiq_options queue: :low, retry: false

  def add_to_tracker env, method_name, *args
    Tracker.new({ env: env }).send method_name, *args
  end

  def mark_last_seen user_id, opts={}
    time = Time.at(opts['time'])
    attributes = {
      user_id: user_id,
      created_at: time,
      event: opts['event'],
      ip: opts['ip'],
      referrer_url: opts['referrer_url'],
      session_id: opts['session_id'],
      landing_url: opts['landing_url'],
      initial_referrer: opts['initial_referrer'],
      request_url: opts['request_url'],
    }
    UserActivity.create attributes
    User.find(user_id).update_last_seen! time
  end
end
