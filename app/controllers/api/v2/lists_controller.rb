class Api::V2::ListsController < Api::V2::BaseController
  before_filter -> { doorkeeper_authorize! :bookmark }
  before_filter :load_list, only: [:link_project, :unlink_project]

  def index
    project_lists = ProjectCollection.where(project_id: params[:project_id], collectable_type: 'Group').joins("INNER JOIN groups ON project_collections.collectable_id = groups.id AND groups.type = 'List'").pluck('groups.id')

    lists = current_user.lists.order("LOWER(groups.full_name)")

    if current_user.is? :admin
      lists += List.includes(:members).where(members: { group_id: nil }).order("LOWER(groups.full_name)")
    end

    render json: { lists: ListCollectionJsonDecorator.new(lists, project_lists: project_lists).node }
  end

  def create
    @list = List.new params[:group]
    authorize! :create, @list

    @list.pryvate = true
    @list.members.new user_id: current_user.id

    if @list.save
      render status: :ok, json: { list: ListJsonDecorator.new(@list).node }
    else
      render status: :unprocessable_entity, json: { errors: @list.errors }
    end
  end

  def link_project
    @project = BaseArticle.find params[:project_id]
    @list.projects << @project unless ProjectCollection.exists? @project.id, 'Group', @list.id

    render status: :ok, nothing: true
  end

  def unlink_project
    @project = BaseArticle.find params[:project_id]
    @list.projects.destroy @project

    render status: :ok, nothing: true
  end

  private
    def load_list
      @list = List.find params[:id]
      authorize! :manage, @list
    end
end