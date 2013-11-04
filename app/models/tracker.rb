# wrapper to take tracking logic away from controllers
class Tracker
  def alias_user user
    user = User.find_by_id user_id
    old_account = user.find_invite_request
    return unless old_account
    @tracker.alias distinct_id_for(user), { distinct_id: distinct_id_for(old_account) }
  end

  def distinct_id_for user
    user ? "#{user.class.name.underscore}_#{user.id}" : nil
  end

  def enqueue method_name, *args
    Resque.enqueue TrackerQueue, @tracker.instance_variable_get('@env'), method_name, *args
  end

  def initialize options={}
    @tracker = Mixpanel::Tracker.new MIXPANEL_API_TOKEN, options
  end

  def update_user user_id, properties={}
    user = User.find_by_id user_id
    @tracker.set distinct_id_for(user), properties
  end

  def record_event event_name, user_id=nil, properties={}
    options = { test: Rails.env == 'development' }
    user = User.find_by_id user_id
    properties.merge!({ distinct_id: distinct_id_for(user), mp_name_tag: user.try(:name) })
    @tracker.track event_name, properties, options
  end
end