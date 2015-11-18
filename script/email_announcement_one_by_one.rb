# send an announcement email

context_id = #announcement_id
announcement = Announcement.find context_id
platform = announcement.threadable
notification_type = 'email'
platform.followers.with_subscription(notification_type, 'follow_platform_activity').order("users.id").each do |user|
  puts "user_id: " + user.id.to_s
  context = {}
  context[:model] = context[:announcement] = announcement
  context[:platform] = platform
  context[:user] = user
  BaseMailer.deliver_email(context, 'new_announcement', {}).deliver_now!
end