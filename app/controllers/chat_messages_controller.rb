class ChatMessagesController < ApplicationController
  before_filter :authenticate_user!, except: [:incoming_slack]
  protect_from_forgery except: [:incoming_slack]

  def index
    @group = load_with_slug
    instance_variable_set "@#{@group.identifier}", @group
    @chat_messages = ChatMessage.where(group_id: @group.id).includes(:user).includes(user: :avatar).order(created_at: :asc).limit(100)
  end

  def create
    @group = Group.find params[:group_id]
    @message = ChatMessage.new params[:chat_message]
    @message.user = current_user
    @message.group = @group

    if @message.save
      Pusher.trigger_async "presence-group_#{@message.group_id}", 'new:message', {
        tpl: [{
          content: render_to_string(@message),
          target: '#chat .messages',
        }]
      }
      post_to_slack @message, @group.slack_hook_url if @group.slack_hook_url.present?
      render status: :ok, nothing: true
    else
      render status: :unprocessable_entity, json: @message.errors
    end
  end

  def slack_settings
    @auth = Authorization.where(user_id: current_user.id, provider: 'Slack').first_or_initialize
  end

  def save_slack_settings
    @auth = Authorization.where(user_id: current_user.id, provider: 'Slack').first_or_initialize
    @auth.uid = params[:authorization][:uid]

    if @auth.save
      redirect_to current_user, notice: 'Slack settings saved.'
    else
      render :slack_settings
    end
  end

  def incoming_slack
    @group = Group.find params[:group_id]
    render status: :unauthorized, json: { text: 'Unauthorized. Please check that you have configured Slack correctly in the platform page settings.' } and return unless params[:token] == @group.slack_token

    user = User.joins(:authorizations).where(authorizations: { uid: params[:user_name], provider: 'Slack' }).first
    render status: :unprocessable_entity, json: { text: "Couldn't post message to chat, user '#{params[:user_name]}' unknown. Please authenticate." } and return unless user

    @message = ChatMessage.new body: params[:text]
    @message.user = user
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
      render status: :unprocessable_entity, json: { text: @message.errors.full_messages.to_sentence }
    end
  end

  def post_to_slack message, slack_hook_url
    SlackQueue.perform_async 'post', slack_hook_url, @message.body, @message.user.name, @message.user.decorate.avatar(:thumb)
  end
end