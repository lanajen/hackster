class ChatMessagesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @group = load_with_slug
    @chat_messages = ChatMessage.where(group_id: @group.id).order(created_at: :asc).limit(100)
  end

  def create
    @message = ChatMessage.new params[:chat_message]
    @message.user = current_user
    @message.group_id = params[:group_id]

    if @message.save
      render
    else
      render status: :unprocessable_entity, json: @message.errors
    end
  end
end