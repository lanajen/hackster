class Api::V1::NotificationsController < Api::V1::BaseController
  after_action :mark_notifications_as_read
  respond_to :js, :html

  def index
    @notification_receipts = user_signed_in? ? current_user.receipts.for_notifications.includes(:receivable).order(created_at: :desc).limit(10) : []
  end

  private
    def mark_notifications_as_read
      current_user.mark_has_no_unread_notifications! if user_signed_in?
    end
end