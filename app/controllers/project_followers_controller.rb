class ProjectFollowersController < ApplicationController
  before_filter :authenticate_user!, except: [:index]
#  load_resource :project

  def create
    @project = Project.find params[:id]
    current_user.follow_project @project
    redirect_to project_url(@project), notice: t('follower.project.new_follow', project_name: @project.name)
  end

  def destroy
    @project = Project.find params[:id]
    current_user.unfollow_project @project
    redirect_to project_url(@project), notice: t('follower.project.new_unfollow', project_name: @project.name)
  end
end