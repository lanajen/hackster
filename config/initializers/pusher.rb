if Rails.env == 'production'
  PUSHER_API_KEY = 'a052792b761bf6079a9a'

  Pusher.url = "http://a052792b761bf6079a9a:6a014511aba4d40c44b4@api.pusherapp.com/apps/102210"
else
  PUSHER_API_KEY = '75e942d50116c713a8ec'

  Pusher.url = "http://75e942d50116c713a8ec:a23def06654e3cfb70b8@api.pusherapp.com/apps/102218"
end