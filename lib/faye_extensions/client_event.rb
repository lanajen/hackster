require 'hashie'
require 'redis'
require 'redis/namespace'

module Faye
  class ClientThing
    def outgoing(message, callback)
      message['ext'] ||= {}
      message['ext']['client_event'] = 'on'
      callback.call(message)
    end
  end

  class ClientEvent
    MONITORED_CHANNELS = [ '/meta/subscribe', '/meta/disconnect' ]

    def incoming(message, callback)
      # puts 'client'
      # puts message.inspect
      return callback.call(message) unless MONITORED_CHANNELS.include? message['channel']
      # puts 'went through'

      msg = Hashie::Mash.new(message)
      action = msg.channel.split('/').last
      user_id = msg.data.user_id
      client_id = msg.clientId
      # puts action.to_s
      # puts user_id.to_s

      if action == 'subscribe'
        channel = msg.subscription
        # puts channel.to_s
        subscribe_user_to_channel user_id, channel, client_id
        # faye_client.publish channel, { message: 'User entered' }
      elsif action == 'disconnect'
        # channels = channels_for_user user_id
        # channels.each do |channel|
        # end
        # begin
          # puts 'disconnecting'
          if channel = redis.get("client:#{client_id}:channel")
            # puts 'channel: ' + channel
            disconnect_user_from_channel user_id, channel, client_id
            # puts 'disconnected'
            # faye_client.publish channel, { disconnected: user_id }
          end
        # rescue => e
        #   puts "error: " + e.inspect
        # end
      end

      # if name = get_client(faye_msg.clientId, faye_action)
      #   faye_client.publish('/messages/new', build_hash(name, faye_action))
      # end
      callback.call(message)
    end

    def subscribe_user_to_channel user_id, channel_id, client_id
      redis.sadd channel_id, user_id unless redis.sismember channel_id, user_id
      redis.sadd "user:#{user_id}", channel_id unless redis.sismember "user:#{user_id}", channel_id
      redis.set "client:#{client_id}:channel", channel_id
    end

    def disconnect_user_from_channel user_id, channel_id, client_id
      redis.srem channel_id, user_id
      redis.srem "user:#{user_id}", channel_id
      redis.del "client:#{client_id}:channel"
    end

    def get_user_id_from_client_id client_id
      redis.get "client:#{client_id}"
    end

    # def channel_users channel_id
    #   redis.smembers channel_id
    # end

    def channels_for_user user_id
      redis.smembers "user:#{user_id}"
    end

    def redis
      @redis ||= ::Redis::Namespace.new :faye, redis: ::Redis.new($redis_config)
    end

    def faye_client
      return @faye_client if @faye_client

      @faye_client = Client.new('http://www.localhost.local:5000/faye')
      @faye_client.add_extension ClientThing.new
      @faye_client
    end

    # def build_hash(name, action)
    #   message_hash = {}
    #   if action == 'subscribe'
    #     message_hash['message'] = { 'content' => "#{name} entered."}
    #   elsif action == 'disconnect'
    #     message_hash['message'] = { 'content' => "#{name} left." }
    #   end

    #   message_hash
    # end
  end
end