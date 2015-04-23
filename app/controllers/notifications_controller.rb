class NotificationsController < ApplicationController
  before_filter :authenticate_user!

  def index
    title "Notifications"

    @receipts = current_user.receipts.for_notifications.includes(:receivable).order(created_at: :desc)
    current_user.mark_has_no_unread_notifications!
  end

  def edit
  end

  def update
    if current_user.update_attributes params[:user]
      redirect_to current_user, notice: "Notification preferences saved."
    else
      render :edit
    end
  end
end