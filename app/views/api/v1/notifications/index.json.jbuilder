json.notifications @notifications do |n|
  json.message n.decorate.message
  json.time time_diff_in_natural_language n.created_at, Time.now, ' ago'
end