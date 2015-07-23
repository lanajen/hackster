class Api::V1::ListsController < Api::V1::BaseController
  before_filter :authenticate_user!
  before_filter :load_list, only: [:link_project, :unlink_project]

  def index
    @project_lists = ProjectCollection.where(project_id: params[:project_id], collectable_type: 'Group').joins("INNER JOIN groups ON project_collections.collectable_id = groups.id AND groups.type = 'List'").pluck('groups.id')

    # @lists = if current_user.is? :admin
    #   List.where(type: 'List').order(:full_name)
    # else
    #   current_user.lists.order(:full_name)
    # end
    @lists= []
  end

  def create
    @list = List.new params[:group]
    authorize! :create, @list

    @list.members.new user_id: current_user.id

    if @list.save
      redirect_to @list, notice: "Welcome to your new list!"
    else
      render 'groups/lists/new'
    end
  end

  def link_project
    @project = Project.find params[:project_id]
    @list.projects << @project unless ProjectCollection.exists? @project.id, 'Group', @list.id

    render status: :ok, nothing: true
  end

  def unlink_project
    @project = Project.find params[:project_id]
    @list.projects.destroy @project

    render status: :ok, nothing: true
  end

  private
    def load_list
      @list = List.find params[:id]
      authorize! :manage, @list
    end
end