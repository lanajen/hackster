class NotificationsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @receipts = current_user.receipts.for_notifications.includes(:receivable).order(created_at: :desc)
  end

  # def destroy
  #   current_user.hide_notification! params[:notif]
  #   target = CGI::unescape params[:close] if params[:close]

  #   render status: :ok, text: "$('#{target}').slideUp(100);"
  # end
end