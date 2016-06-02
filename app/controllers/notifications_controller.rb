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
    if params[:unsubscribe]
      current_user.unsubscribe_from_all
    else
      current_user.assign_attributes params[:user]
    end

    if current_user.save
      redirect_to current_user, notice: "Notification preferences saved."
    else
      render :edit
    end
  end

  def update_from_link
    if params[:unsubscribe]
      current_user.unsubscribe_from! :email, params[:unsubscribe]
      flash[:notice] = "Notification preferences saved."
    elsif params[:frequency]
      current_user.project_email_frequency_proxy = params[:frequency]
      current_user.save
      flash[:notice] = "Notification preferences saved."
    end

    redirect_to edit_notifications_path
  end
end