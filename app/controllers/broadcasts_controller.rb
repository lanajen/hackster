class BroadcastsController < ApplicationController
  before_filter :authenticate_user!

  def index
    title "Recent activity"
    @custom_broadcasts = Broadcast.where("(project_id IN (?)) OR (user_id IN (?))", current_user.followed_projects.pluck(:id), current_user.followed_users.pluck(:id)).order(created_at: :desc).limit(50)

    @broadcasts = Broadcast.order(created_at: :desc).limit(50) if @custom_broadcasts.empty?
  end
end