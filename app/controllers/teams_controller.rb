class TeamsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_project
  respond_to :html
  layout 'project'

  def edit
    @team = @project.team
    authorize! :update, @team
  end

  def update
    @team = @project.team
    authorize! :update, @team

    if @team.update_attributes(params[:team])
      @project.team = @team
      flash[:notice] = 'Team saved.'
      current_user.broadcast :update, @project.id, 'Project'
      respond_with @project
    else
      render action: 'edit'
    end
  end
end