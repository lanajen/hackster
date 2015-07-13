class Api::V1::NotificationsController < Api::V1::BaseController
  respond_to :js, :html

  def index
    @notifications = user_signed_in? ? current_user.notifications.order(created_at: :desc).limit(10) : []
    current_user.mark_has_no_unread_notifications! if user_signed_in?
  end
end