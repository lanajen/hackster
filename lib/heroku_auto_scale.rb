require 'heroku-api'

module HerokuResqueAutoScale
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

  def after_enqueue_scale_up(*args)
    [
      {
        :workers => 1, # This many workers
        :job_count => 1 # For this many jobs or more, until the next level
      },
      {
        :workers => 2,
        :job_count => 15
      },
      {
        :workers => 3,
        :job_count => 25
      # },
      # {
      #   :workers => 4,
      #   :job_count => 40
      # },
      # {
      #   :workers => 5,
      #   :job_count => 60
      }
    ].reverse_each do |scale_info|
      # Run backwards so it gets set to the highest value first
      # Otherwise if there were 70 jobs, it would get set to 1, then 2, then 3, etc

      # If we have a job count greater than or equal to the job limit for this scale info
      if Scaler.job_count >= scale_info[:job_count]
        # Set the number of workers unless they are already set to a level we want. Don't scale down here!
        Scaler.workers = scale_info[:workers]
        break # We've set or ensured that the worker count is high enough
      end
    end
  end
end