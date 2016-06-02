module MixpanelMethods
  def self.included base
    base.include ClassMethods
  end

  module ClassMethods
    def current_mixpanel_user user=nil
      cookies[:mixpanel_user] ||= set_current_mixpanel_user(user)
    end

    def distinct_id_for user=nil
      user ? "user_#{user.id}" : (request.session_options[:id].present? ? "session_#{request.session_options[:id]}" : nil)
    end

    def reset_current_mixpanel_user
      cookies[:mixpanel_user] = distinct_id_for nil
    end

    def set_current_mixpanel_user user=nil
      cookies[:mixpanel_user] = distinct_id_for(user || current_user)
    end

    def track_alias user=nil
      old_distinct_id = current_mixpanel_user
      new_distinct_id = set_current_mixpanel_user(user)
      tracker.enqueue 'alias_user', new_distinct_id, old_distinct_id if tracking_activated?
    end

    def track_event event_name, properties={}, user=nil
      properties.merge! signed_in: !!user_signed_in?
      properties.merge! ref: params[:ref] if params[:ref]
      tracker.enqueue 'record_event', event_name, current_mixpanel_user(user), properties if tracking_activated?
    end

    def track_user properties, user=nil
      tracker.enqueue 'update_user', current_mixpanel_user(user), properties.merge({ ip: request.ip }) if tracking_activated?
    end

    def tracker
      @tracker ||= Tracker.new tracker_options
    end

    def tracker_options
      {
        # env: request.env,
        env: {
          'REMOTE_ADDR' => request.env['REMOTE_ADDR'],
          'HTTP_X_FORWARDED_FOR' => request.env['HTTP_X_FORWARDED_FOR'],
          # 'rack.session' => request.env['rack.session'],
          'mixpanel_events' => request.env['mixpanel_events'],
        }
      }
    end
  end
end
