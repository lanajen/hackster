class Admin::ProjectsController < Admin::BaseController
  before_filter :load_resource, except: [:index, :new, :create]

  def index
    title "Admin / Projects - #{safe_page_params}"
    @fields = {
      'created_at' => 'projects.created_at',
      'made_public_at' => 'projects.made_public_at',
      'status' => 'projects.workflow_state',
      'private' => 'projects.private',
      'name' => 'projects.name',
      'type' => 'projects.type',
    }

    params[:sort_order] ||= 'DESC'

    @base_articles = params[:approval_needed] ? BaseArticle.need_review : BaseArticle
    @base_articles = filter_for @base_articles, @fields
  end

  def new
    title "Admin / Projects / New"

    model_class = if params[:type] and params[:type].in? BaseArticle::MACHINE_TYPES.keys
      BaseArticle::MACHINE_TYPES[params[:type]].constantize
    else
      BaseArticle
    end
    @base_article = model_class.new params[:base_article]
  end

  def create
    model_class = if params[:base_article] and params[:base_article][:type] and params[:base_article][:type].in? BaseArticle::MACHINE_TYPES.values
      params[:base_article][:type].constantize
    else
      BaseArticle
    end
    @base_article = model_class.new params[:base_article]

    if @base_article.save
      redirect_to admin_projects_path, :notice => 'New project created'
    else
      render :new
    end
  end

  def edit
    title "Admin / Projects / Edit #{@base_article.name}"
  end

  def update
    if @base_article.update_attributes(params[:base_article])
      @team_members = @base_article.users
      redirect_to admin_projects_path, :notice => 'Project successfuly updated'
    else
      render :edit
    end
  end

  def destroy
    @base_article.destroy
    redirect_to admin_projects_path, :notice => 'Project successfuly deleted'
  end

  private
    def check_authorization_for_admin
      raise CanCan::AccessDenied unless current_user.is? :admin, :hackster_moderator
    end

    def load_resource
      @base_article =  BaseArticle.find params[:id]
    end
end