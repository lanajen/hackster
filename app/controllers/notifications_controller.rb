class NotificationsController < ApplicationController
  def destroy
    current_user.hide_notification! params[:notif]
    target = CGI::unescape params[:close] if params[:close]

    render status: :ok, text: "$('#{target}').slideUp(100);"
  end
end