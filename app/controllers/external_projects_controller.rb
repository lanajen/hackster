class ExternalProjectsController < ApplicationController
  load_and_authorize_resource :project, parent: false, only: [:edit, :update]
  respond_to :html

  def show
    @project = Project.external.find_by_id!(params[:id]).decorate
    impressionist_async @project, '', unique: [:session_hash]
    title @project.name
    meta_desc @project.one_liner

    if is_whitelabel?
      @comments = @project.comments.joins(:user).where(users: { enable_sharing: true }).includes(:user).includes(:parent).includes(user: :avatar)
      @respecting_users = @project.respecting_users.where(users: { enable_sharing: true }).includes(:avatar) if @project.public?
    else
      @comments = @project.comments.includes(:user).includes(:parent)#.includes(user: :avatar)
      @respecting_users = @project.respecting_users.includes(:avatar) if @project.public?
    end

    # track_event 'Viewed project', @project.to_tracker.merge({ own: !!current_user.try(:is_team_member?, @project) })
  end

  def redirect_to_show
    @project = Project.external.find_by_slug!(params[:slug])
    redirect_to external_project_path(@project), status: 301
  end

  def edit
    title 'Page settings'
  end

  def update
    if @project.update_attributes(params[:project])
      notice = "#{@project.name} was successfully updated."
      respond_with @project do |format|
        format.html do
          flash[:notice] = notice
          redirect_to @project
        end
      end
    else
      @project = @project.decorate
      render action: :edit
    end
  end
end