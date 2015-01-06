# FayeRails::Controller::Monitor.class_eval do

#     def current_user data
#       return @current_user if @current_user

#       if data and data['user_id']
#         @current_user = User.find_by_id data['user_id']
#       end
#     end

#     def publish(channel, message, endpoint=nil)
#       client.publish(channel, message)
#     end

#     def client endpoint=nil
#       @client ||= FayeRails.client(endpoint)
#     end

#     def get_user_id_from_client_id client_id
#       redis.get "client:#{client_id}"
#     end

#     def subscribe_user_to_channel user_id, channel_id
#       redis.sadd channel_id, user_id unless redis.sismember channel_id, user_id
#       redis.sadd "user:#{user_id}", channel_id unless redis.sismember "user:#{user_id}", channel_id
#     end

#     def disconnect_user_from_channel user_id, channel_id
#       redis.srem channel_id, user_id
#       redis.srem "user:#{user_id}", channel_id
#     end

#     # def channel_users channel_id
#     #   redis.smembers channel_id
#     # end

#     def channels_for_user user_id
#       redis.smembers "user:#{user_id}"
#     end

#     def redis
#       @redis ||= ::Redis::Namespace.new :faye, redis: ::Redis.new($redis_config)
#     end
# end

# class Faye::ChatsController < FayeRails::Controller
#   channel '/chats/*' do
#     # puts "channel: " + inspect

#     subscribe do
#       puts "Received on #{channel}"
#     end

#     monitor :subscribe do
#       # begin
#       #   puts inspect
#       #   # puts current_user(data).to_s
#       #   puts '2'
#         # if user_id = get_user_id_from_client_id(client_id)
#       #     puts '4'
#           # subscribe_user_to_channel user_id, channel
#       #     publish channel, { message: 'User entered' }, 'http://www.localhost.local:5000/faye'
#         # end
#       #   puts '3'
#       #   puts "user_id: #{user_id}"
#         puts "Client #{client_id} subscribed to #{channel}."
#       # rescue => e
#       #   puts "ee: " + e.inspect
#       # end
#     end
#     monitor :unsubscribe do
#       # user_id = get_user_id_from_client_id client_id
#       # disconnect_user_from_channel user_id, channel
#       # publish channel, { unsub: { user_id: user_id }}
#       puts "Client #{client_id} unsubscribed from #{channel}."
#     end
#     monitor :publish do
#       puts "#{Time.now}: Client #{client_id} published #{data.inspect} to #{channel}."

#       # created_at = if data['created_at'].present?
#       #   Time.parse(data['created_at'])
#       # else
#       #   Time.now
#       # end

#       # ChatMessage.create user_id: data['user_id'], message: data['message'],
#       #   group_id: data['group_id'], created_at: created_at
#     end

#     filter :in do
#       # if the message won't save we block it
#       # message = ChatMessage.create user_id: data['user_id'], message: data['message'],
#       #   group_id: data['group_id'], created_at: created_at

#       # message.valid? ? pass : block(message.errors.messages)
#       pass
#     end
#   end

#   # private
#   #   def current_user data
#   #     return @current_user if @current_user

#   #     if data and data['user_id']
#   #       @current_user = User.find_by_id data['user_id']
#   #     end
#   #   end

#   #   def get_user_id_from_client_id client_id
#   #     redis.get "client:#{client_id}"
#   #   end

#   #   def subscribe_user_to_channel user_id, channel_id
#   #     redis.sadd channel_id, user_id unless redis.sismember channel_id, user_id
#   #     redis.sadd "user:#{user_id}", channel_id unless redis.sismember "user:#{user_id}", channel_id
#   #   end

#   #   def disconnect_user_from_channel user_id, channel_id
#   #     redis.srem channel_id, user_id
#   #     redis.srem "user:#{user_id}", channel_id
#   #   end

#   #   # def channel_users channel_id
#   #   #   redis.smembers channel_id
#   #   # end

#   #   def channels_for_user user_id
#   #     redis.smembers "user:#{user_id}"
#   #   end

#   #   def redis
#   #     @redis ||= ::Redis::Namespace.new :faye, redis: ::Redis.new($redis_config)
#   #     puts @redis.inspect
#   #     @redis
#   #   rescue => e
#   #     puts e.inspect
#   #   end
# end