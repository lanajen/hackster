# wrapper to take tracking logic away from controllers
class Tracker
  def alias_user new_distinct_id, old_distinct_id
    # user = find_user user_id, user_class
    @tracker.alias new_distinct_id, { distinct_id: old_distinct_id }
    # old_account = user.find_invite_request
    # return unless old_account
    # @tracker.alias distinct_id_for(user.id, user.class), { distinct_id: distinct_id_for(old_account.id, old_account.class) }
  end

  # def distinct_id_for user
  #   user ? "#{user.class.name.underscore}_#{user.id}" : nil
  # end

  # def distinct_id_for user_id, user_class
  #   "#{user_class.to_s.underscore}_#{user_id}"
  # end

  def enqueue method_name, *args
    Resque.enqueue TrackerQueue, @tracker.instance_variable_get('@env'), method_name, *args
  end

  # def find_user user_id, user_class
  #   user_class.constantize.find_by_id user_id
  # rescue
  #   nil
  # end

  def initialize options={}
    @tracker = Mixpanel::Tracker.new MIXPANEL_API_TOKEN, options
  end

  def update_user distinct_id, properties={}
    # user = find_user user_id, user_class
    # @tracker.set distinct_id_for(user), properties
    # distinct_id = distinct_id_for user_id, user_class
    @tracker.set distinct_id, properties
  end

  def record_event event_name, distinct_id, properties={}
    options = { test: Rails.env == 'development' }
    # distinct_id = distinct_id_for user_id, user_class
    properties.merge!({ distinct_id: distinct_id })
    # user = find_user user_id, user_class
    # properties.merge!({ distinct_id: distinct_id_for(user) })
    # properties.merge!({ mp_name_tag: user.name }) if user and user.class == 'User'
    @tracker.track event_name, properties, options
  end
end