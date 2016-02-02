json.notifications @notification_receipts do |receipt|
  notification = receipt.receivable
  json.message notification.decorate.message
  json.time time_diff_in_natural_language notification.created_at, Time.now, ' ago'
  json.read receipt.read
end