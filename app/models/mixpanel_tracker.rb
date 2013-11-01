class MixpanelTracker
  # wrapper to take tracking logic away from controllers
  def initialize options={}
    @tracker = Mixpanel::Tracker.new MIXPANEL_API_TOKEN, options
  end

  def set distinct_id_or_request_properties, properties={}, options={}
    @tracker.set distinct_id_or_request_properties, properties, options
  end

  def track event_name, properties={}, options={}
    options.merge!({ test: Rails.env == 'development' })
    @tracker.track event_name, properties, options
  end
end