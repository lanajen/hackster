class TrackerQueue < BaseWorker
  sidekiq_options queue: :low, retry: false

  def add_to_tracker env, method_name, *args
    Tracker.new({ env: env }).send method_name, *args
  end

  def mark_last_seen user_id, opts={}
    attributes = {
      user_id: user_id,
      created_at: opts['time'],
      event: opts['event'],
      ip: opts['ip'],
      referrer_url: opts['referrer_url'],
      session_id: opts['session_id'],
      landing_url: opts['landing_url'],
      initial_referrer: opts['initial_referrer'],
      request_url: opts['request_url'],
    }

    Keen.publish "page_request", attributes
    UserWorker.perform_async 'update_last_seen', user_id, opts['time'] if user_id
  end
end
