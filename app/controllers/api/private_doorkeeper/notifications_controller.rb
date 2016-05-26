class Api::PrivateDoorkeeper::NotificationsController < Api::PrivateDoorkeeper::BaseController
  before_action :doorkeeper_authorize_user_without_scope!
  after_action :mark_notifications_as_read

  def index
    notification_receipts = current_user.receipts.for_notifications.includes(:receivable).order(created_at: :desc).limit(10)

    render json: { notifications: BaseCollectionJsonDecorator.new(notification_receipts, current_user: current_user).node }
  end

  private
    def mark_notifications_as_read
      current_user.mark_has_no_unread_notifications!
    end
end