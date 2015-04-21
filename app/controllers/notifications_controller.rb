class NotificationsController < ApplicationController
  before_filter :authenticate_user!

  def index
    title "Notifications"

    @receipts = current_user.receipts.for_notifications.includes(:receivable).order(created_at: :desc)
    current_user.mark_has_no_unread_notifications!
  end
end