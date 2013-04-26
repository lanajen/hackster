class TeamMembersController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  load_and_authorize_resource only: [:destroy]
  before_filter :load_project
  respond_to :html

  def new
    @team_member = @project.team_members.new
    authorize! :create, @team_member
  end

  def create
    @team_member = @project.team_members.new(params[:team_member])
    authorize! :create, @team_member

    if @team_member.save
      flash[:notice] = 'Team member added.'
      current_user.broadcast :update, @project.id, 'Project'
      respond_with @project
    else
      render action: 'new'
    end
  end

  def destroy
    @team_member.destroy

    flash[:notice] = 'Team member removed.'
    respond_with @project
  end

  private
    def load_project
      @project = Project.find params[:project_id]
    end
end