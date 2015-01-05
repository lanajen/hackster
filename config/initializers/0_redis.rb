# this file defines $redis_config which is required by other initializers
# so it needs to be loaded first

# conf = YAML::load(File.open(File.join(Rails.root, 'config/server/redis.yml')))[Rails.env]
conf = YAML::load(File.open(File.expand_path('../../server/redis.yml', __FILE__)))[Rails.env]

$redis_config = if ENV['REDISTOGO_URL'].present?
  { url: ENV['REDISTOGO_URL'] }
else
  { host: conf['host'], port: conf['port'], login: conf['login'],
    password: conf['password'] }
end