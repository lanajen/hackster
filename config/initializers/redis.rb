conf = YAML::load(File.open(File.join(Rails.root, 'config/server/redis.yml')))[Rails.env]
if ENV['REDISTOGO_URL'].present?
  $redis = Redis.new(:url => ENV['REDISTOGO_URL'])
else
  $redis = Redis.new(:host => conf['host'], :port => conf['port'], :login => conf['login'],
    :password => conf['password'])
end