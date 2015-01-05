class ChatMessagesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @group = load_with_slug
    instance_variable_set "@#{@group.identifier}", @group
    @chat_messages = []#ChatMessage.where(group_id: @group.id).includes(:user).includes(user: :avatar).order(created_at: :asc).limit(100)

    # redis = Redis::Namespace.new :faye, redis: Redis.new($redis_config)
    # participants_ids = redis.smembers "/chats/#{@group.id}"
    # puts participants_ids.to_s
    # @participants = User.where(id: participants_ids)

    # faye_client.publish "/chats/#{@group.id}", {
    #   tpl: {
    #     content: render_to_string(partial: 'chat_messages/user', locals: { user: current_user }),
    #     target: '#chat .chat-participants',
    #   }
    # }
  end

  def create
    @message = ChatMessage.new params[:chat_message]
    @message.user = current_user
    @message.group_id = params[:group_id]

    if @message.valid?#save
      render
    else
      render status: :unprocessable_entity, json: @message.errors
    end
  end
end