web: bundle exec unicorn -p $PORT -c ./config/server/unicorn.rb
worker: bundle exec sidekiq -q critical,10 -q default,5 -q low,2 -c 3