class ChatMessagesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @group = load_with_slug
    instance_variable_set "@#{@group.identifier}", @group
    @chat_messages = ChatMessage.where(group_id: @group.id).includes(:user).includes(user: :avatar).order(created_at: :asc).limit(100)
  end

  def create
    @message = ChatMessage.new params[:chat_message]
    @message.user = current_user
    @message.group_id = params[:group_id]

    if @message.save
      Pusher.trigger_async "presence-group_#{@message.group_id}", 'new:message', {
        tpl: [{
          content: render_to_string(@message),
          target: '#chat .messages',
        }]
      }
      render status: :ok, nothing: true
    else
      render status: :unprocessable_entity, json: @message.errors
    end
  end
end