class ExternalProjectsController < ApplicationController
  before_filter :load_project_with_hid, only: [:show]
  before_filter :load_and_authorize_resource, only: [:edit, :update]
  respond_to :html

  def show
    impressionist_async @project, '', unique: [:session_hash]
    title @project.name
    meta_desc @project.one_liner

    @respecting_users = @project.respecting_users.publyc.includes(:avatar) if @project.publyc?

    if is_whitelabel?
      @comments = @project.comments.joins(:user).where(users: { enable_sharing: true }).includes(:user).includes(:parent).includes(user: :avatar)
      @respecting_users = @respecting_users.where(users: { enable_sharing: true }) if @project.publyc?
    else
      @comments = @project.comments.includes(:user).includes(:parent)#.includes(user: :avatar)
    end

    @project = @project.decorate

    # track_event 'Viewed project', @project.to_tracker.merge({ own: !!current_user.try(:is_team_member?, @project) })
  end

  def redirect_to_show
    @project = ExternalProject.find params[:id]
    redirect_to @project, status: 301
  end

  def edit
    title 'Page settings'
  end

  def update
    if @project.update_attributes(params[:base_article])
      notice = "#{@project.name} was successfully updated."
      respond_with @project do |format|
        format.html do
          flash[:notice] = notice
          redirect_to @project
        end
      end
    else
      render action: :edit
    end
  end

  private
    def load_and_authorize_resource
      @project = ExternalProject.find params[:id]
      authorize! self.action_name, @project
    end
end