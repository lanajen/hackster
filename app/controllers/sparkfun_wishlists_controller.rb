class SparkfunWishlistsController < ApplicationController

  def new
    if user_signed_in?
      @project = Project.new content_type: Project::DEFAULT_CONTENT_TYPE
      @project.build_team
      @project.team.members.new user_id: current_user.id
      @project.save

    end
  end
end