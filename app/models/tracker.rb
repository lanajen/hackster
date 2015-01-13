# wrapper to take tracking logic away from controllers
class Tracker
  def alias_user new_distinct_id, old_distinct_id
    @tracker.alias new_distinct_id, { distinct_id: old_distinct_id }
  end

  def enqueue method_name, *args
    TrackerQueue.perform_async @tracker.instance_variable_get('@env'), method_name, *args
  rescue Timeout::Error
  end

  def initialize options={}
    @tracker = Mixpanel::Tracker.new MIXPANEL_API_TOKEN, options
    @env = options[:env]
  end

  def update_user distinct_id, properties={}
    @tracker.set distinct_id, properties
  end

  def record_event event_name, distinct_id, properties={}
    options = { test: Rails.env == 'development' }
    properties.merge!({ distinct_id: distinct_id })
    @tracker.track event_name, properties, options
  end
end