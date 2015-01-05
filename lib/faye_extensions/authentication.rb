require 'redis'
require 'redis/namespace'

module Faye
  class Authentication
    def incoming(message, request, callback)
      puts message.inspect
      # puts 'auth'
      # puts User.first.inspect
      return callback.call(message) if message['ext'] && 'client_event'.in?(message['ext'])
      # puts 'went through'
      # puts message['channel'].to_s
      # return callback.call(message) unless message['channel'].starts_with? '/chats/'

      message['data'] = {} unless 'data'.in? message

      begin
        if request
          user_id = request.session["warden.user.user.key"][0][0]
          message['data']['user_id'] = user_id
          set_user_id_by_client_id user_id, message['clientId']
          # puts '1'
          if channel = message['channel'] and channel =~ /\A\/chats\//
            message['data']['group_id'] = channel.split(/\//)[2]
            # puts '2'
          end
        end
      rescue => e
        # puts message.inspect
        puts e.inspect
        puts "failed auth"
        message['error'] = '401::Access denied'
      end

      callback.call(message)
    end

    def redis
      @redis ||= ::Redis::Namespace.new :faye, redis: ::Redis.new($redis_config)
    end

    def set_user_id_by_client_id user_id, client_id
      redis.set "client:#{client_id}", user_id
    end
  end
end