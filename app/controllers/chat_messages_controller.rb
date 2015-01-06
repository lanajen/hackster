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
  end

  def create
    @message = ChatMessage.new params[:chat_message]
    @message.user = current_user
    @message.group_id = params[:group_id]

    if @message.valid?#save
      faye_client.publish "/chats/#{@message.group_id}", {
        tpl: [{
          content: render_to_string(@message),
          target: '#chat .messages',
        }]
      }
      # render
      render status: :ok, nothing: true
    else
      render status: :unprocessable_entity, json: @message.errors
    end
  end

  private
    def faye_client
      @faye_client ||= Faye::Client.new("http://#{APP_CONFIG['full_host']}/faye")
    end
end