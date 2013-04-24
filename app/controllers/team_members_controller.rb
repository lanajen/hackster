class TeamMembersController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
#  load_and_authorize_resource
  skip_load_resource only: [:create]
  before_filter :load_project
  respond_to :html

  def new
    @team_member = @project.team_members.new
  end

  def create
    @team_member = @project.team_members.new(params[:team_member])

    if @team_member.save
      flash[:notice] = 'Team member added.'
      respond_with @project
    else
      render action: 'new'
    end
  end

  def destroy
    @team_member = TeamMember.find params[:id]
    @team_member.destroy

    flash[:notice] = 'Team member removed.'
    respond_with @project
  end

  private
    def load_project
      @project = Project.find params[:project_id]
    end
end