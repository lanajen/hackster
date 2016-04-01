class EmbedWidgetsController < ApplicationController

  def index
    @user = current_user
    @username = current_user.user_name
    @project_count = current_user.projects_count
    @followers = current_user.followers_count
    @respects = current_user.respects_count
    @id = current_user.id
  end

end

