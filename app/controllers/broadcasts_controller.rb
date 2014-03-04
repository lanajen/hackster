class BroadcastsController < ApplicationController
  def index
    title "Recent activity"
    @broadcasts = Broadcast.where('created_at > ?', 10.days.ago).order(created_at: :desc)

    if user_signed_in?
      @custom_broadcasts = Broadcast.where("(project_id IN (?)) OR (user_id IN (?))", current_user.followed_projects.pluck(:id), current_user.followed_users.pluck(:id)).where('created_at > ?', 15.days.ago).order(created_at: :desc)
    end
  end
end