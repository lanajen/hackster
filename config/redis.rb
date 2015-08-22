# this file defines $redis_config which is required by other initializers
# so it needs to be loaded first

conf = { 'host' => 'localhost', 'port' => 6379 }

$redis_config = if ENV['OPENREDIS_URL'].present?
  { url: ENV['OPENREDIS_URL'] }
else
  { host: conf['host'], port: conf['port'], login: conf['login'],
    password: conf['password'] }
end

module RedisConn
  class << self
    def conn
      @conn ||= Redis.new $redis_config
    end
  end
end