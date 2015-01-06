class Users::PusherAuthenticationsController < ApplicationController
  protect_from_forgery except: :create

  def create
    if current_user
      response = Pusher[params[:channel_name]].authenticate(params[:socket_id], {
        user_id: current_user.id, # => required
        user_info: {
          name: current_user.name,
          email: current_user.email,
          url: url_for(current_user),
          avatar: current_user.decorate.avatar(:thumb),
          tpl: render_to_string(partial: 'chat_messages/participant',
            locals: { participant: current_user }),
        }
      })
      render json: response
    else
      render text: "Forbidden", status: '403'
    end
  end
end