web: bundle exec unicorn -p $PORT -c ./config/server/unicorn.rb
worker: bundle exec sidekiq -q critical,7 -q default,5 -q low,3 -q cron,2 -q lowest,1 -c 3