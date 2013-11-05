require 'heroku-api'

module HerokuAutoScaleDown
  # scaler extracted from heroku_auto_scale because we only want scaling down
  module Scaler
    class << self
      @@heroku = Heroku::API.new(:api_key => ENV['HEROKU_API_KEY'],
        :mock => (Rails.env == 'development'))

      def workers=(qty)
        @@heroku.post_ps_scale(ENV['HEROKU_APP'], 'worker', qty.to_s)
      end

      def job_count
        Resque.info[:pending].to_i
      end
    end
  end

  def after_perform_scale_down(*args)
    # Nothing fancy, just shut everything down if we have no jobs
    Scaler.workers = 0 if Scaler.job_count.zero?
  end
end

class TrackerQueue
  extend HerokuAutoScaleDown if Rails.env == 'production'
  @queue = :trackers

  def self.perform env, method_name, *args
    Tracker.new({ env: env }).send method_name, *args
  end
end
