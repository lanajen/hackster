web: bundle exec unicorn -p $PORT -c ./config/server/unicorn.rb
worker: TERM_CHILD=1 RESQUE_TERM_TIMEOUT=10 bundle exec rake resque:work