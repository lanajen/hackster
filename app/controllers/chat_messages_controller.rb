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
      post_to_slack @message, @group.slack_hook_url if @group.slack_hook_url
      render status: :ok, nothing: true
    else
      render status: :unprocessable_entity, json: @message.errors
    end
  end

  def incoming_slack
    # add oauth flow with slack_token
    @group = Group.find params[:group_id]
    render status: :unauthorized, json: { text: 'Unauthorized' } unless params[:channel_id] == @group.slack_channel_id and params[:token] == @group.slack_token

    user = User.joins(:authorizations).where(authorizations: { provider_id: params[:user_id], provider: 'Slack' }).first
    render status: :unprocessable_entity, json: { text: "Couldn't post message to chat, user '#{params[:user_name]}' unknown. Please authenticate." }

    @message = ChatMessage.new body: params[:text]
    @message.user = user
    @message.group_id = params[:group_id]

    @message.save

    Pusher.trigger_async "presence-group_#{@message.group_id}", 'new:message', {
      tpl: [{
        content: render_to_string(@message),
        target: '#chat .messages',
      }]
    }
  end

  def post_to_slack message, slack_hook_url
    require "net/http"
    require "uri"

    uri = URI.parse(slack_hook_url)

    data = {
      'text' => @message.body,
      'username' => @message.user.name,
      'icon_url' => @message.user.decorate.avatar(:thumb)
    }.to_json

    response = Net::HTTP.post_form(uri, payload: data)

    if defined?(EventMachine) && EventMachine.reactor_running?
      http_client = @client.em_http_client(@uri)
      df = EM::DefaultDeferrable.new

      http_client.post({
        :query => @params, :body => @body, :head => @head
      })
      http.callback {
        begin
          df.succeed(handle_response(http.response_header.status, http.response.chomp))
        rescue => e
          df.fail(e)
        end
      }
      http.errback { |e|
        message = "Network error connecting to pusher (#{http.error})"
        Pusher.logger.debug(message)
        df.fail(Error.new(message))
      }

      return df
    else
      http = @client.sync_http_client

      return http.request_async(@verb, @uri, @params, @body, @head)
    end
  end
end