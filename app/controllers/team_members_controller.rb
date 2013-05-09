class TeamMembersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_and_authorize_project
  respond_to :html
  layout 'project'

  def edit
  end

  def update
    if @team_member.update_attributes(params[:project])
      flash[:notice] = 'Team members saved.'
      current_user.broadcast :update, @project.id, 'Project'
      respond_with @project
    else
      render action: 'edit'
    end
  end
end