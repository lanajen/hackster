class Client::ProjectsController < Client::BaseController
  before_filter :load_project, except: [:index, :create, :new, :edit, :redirect_to_last]
  load_and_authorize_resource only: [:index, :create, :new, :edit]
  layout 'project', only: [:edit, :update, :show]
  respond_to :html
  respond_to :js, only: [:edit, :update]
  after_action :allow_iframe, only: :embed

  def index
    title "#{current_platform.name} projects - Page #{params[:page] || 1}"

    # params[:sort] ||= 'recent'
    # @by = params[:by] || 'all'

    # @projects = current_tech.projects
    # if params[:sort] and params[:sort].in? Project::SORTING.keys
    #   @projects = @projects.send(Project::SORTING[params[:sort]])
    # end

    # if params[:by] and params[:by].in? Project::FILTERS.keys
    #   @projects = @projects.send(Project::FILTERS[params[:by]])
    # end

    # @projects = @projects.paginate(page: params[:page])

    get_projects

    respond_to do |format|
      format.html { render layout: 'whitelabel' }
      format.atom { render layout: false }
      format.rss { redirect_to projects_path(params.merge(format: :atom)), status: :moved_permanently }
    end
  end

  # def show
  #   authorize! :read, @project
  #   impressionist_async @project, '', unique: [:session_hash]

  #   title @project.name
  #   @project_meta_desc = "#{@project.one_liner.try(:gsub, /\.$/, '')}. Find this and other hardware projects on Hackster.io."
  #   meta_desc @project_meta_desc
  #   @project = @project.decorate
  #   @widgets = @project.widgets.order(:created_at)

  #   # other projects by same author
  #   @other_projects_count = Project.most_popular.includes(:team_members).where(members:{user_id: @project.users.pluck(:id)}).where.not(id: @project.id).size
  #   if @other_projects_count > 6
  #     @other_projects = Project.most_popular.includes(:team_members).where(members:{user_id: @project.users.pluck(:id)}).where.not(id: @project.id).limit(3)
  #     @last_projects = Project.last_public.includes(:team_members).where(members:{user_id: @project.users.pluck(:id)}).where.not(id: [@project.id] + @other_projects.map(&:id)).limit(3)
  #   else
  #     @other_projects = Project.most_popular.includes(:team_members).where(members:{user_id: @project.users.pluck(:id)}).where.not(id: @project.id)
  #   end
  #   @issue = Feedback.where(threadable_type: 'Project', threadable_id: @project.id).first if @project.collection_id.present? and @project.assignment.present?

  #   # next/previous project in search
  #   if params[:ref] and params[:ref_id] and params[:offset]
  #     offset = params[:offset].to_i
  #     case params[:ref]
  #     when 'assignment'
  #       if @assignment = Assignment.find_by_id(params[:ref_id])
  #         @next = @assignment.projects.order(:created_at).offset(offset + 1).first
  #         @prev = @assignment.projects.order(:created_at).offset(offset - 1).first unless offset.zero?
  #       end
  #     when 'explore'
  #       sort, by = params[:ref_id].split(/_/)

  #       @projects = Project
  #       if sort.in? Project::SORTING.keys
  #         @projects = @projects.send(Project::SORTING[sort])
  #       end

  #       if by.in? Project::FILTERS.keys
  #         @projects = @projects.send(Project::FILTERS[by])
  #       end

  #       @next = @projects.offset(offset + 1).first
  #       @prev = @projects.offset(offset - 1).first unless offset.zero?

  #     when 'search'
  #       params[:q] = params[:ref_id]
  #       params[:type] = 'project'
  #       params[:per_page] = 1
  #       params[:offset] = offset + 1
  #       @next = SearchRepository.new(params).search.results.first
  #       unless offset.zero?
  #         params[:offset] = offset - 1
  #         @prev = SearchRepository.new(params).search.results.first
  #       end
  #       params[:offset] = offset
  #     when 'user'
  #       if @user = User.find_by_id(params[:ref_id])
  #         @next = @user.projects.live.order(start_date: :desc, created_at: :desc).offset(offset + 1).first
  #         @prev = @user.projects.live.order(start_date: :desc, created_at: :desc).offset(offset - 1).first unless offset.zero?
  #       end
  #     end
  #   end

  #   track_event 'Viewed project', @project.to_tracker.merge({ own: !!current_user.try(:is_team_member?, @project) })
  # end

  # def embed
  #   title @project.name
  #   meta_desc "#{@project.one_liner.try(:gsub, /\.$/, '')}. Find this and other hardware projects on Hackster.io."
  #   @project = @project.decorate
  #   render layout: 'embed'

  #   track_event 'Rendered embed thumbnail', @project.to_tracker.merge({ referrer: request.referrer })
  # end

  # def new
  #   initialize_project
  # end

  # def edit
  #   authorize! :update, @project

  #   initialize_project
  # end

  # def create
  #   @project.private = true
  #   @project.build_team
  #   @project.team.members.new(user_id: current_user.id)

  #   if @project.save
  #     flash[:notice] = "#{@project.name} was successfully created."
  #     respond_with @project

  #     track_event 'Created project', @project.to_tracker
  #   else
  #     initialize_project
  #     render action: "new"
  #   end
  # end

  # def update
  #   authorize! :update, @project

  #   if @project.update_attributes(params[:project])
  #     if @project.private_changed? and @project.private == false
  #       current_user.broadcast :new, @project.id, 'Project'

  #       track_event 'Made project public', @project.to_tracker
  #     elsif @project.private == false
  #       current_user.broadcast :update, @project.id, 'Project'
  #     end
  #     @refresh = @project.slug_was_changed?
  #     @project = @project.decorate
  #     @widgets = @project.widgets.order(:created_at)
  #     notice = "#{@project.name} was successfully updated."
  #     respond_with @project do |format|
  #       format.html do
  #         flash[:notice] = notice
  #         redirect_to @project
  #       end
  #       format.js do
  #         flash[:notice] = notice if @refresh
  #       end
  #     end

  #     track_event 'Updated project', @project.to_tracker.merge({ type: 'project update'})
  #   else
  #     initialize_project
  #     render action: "edit"
  #   end
  # end

  # def destroy
  #   authorize! :destroy, @project

  #   @project.destroy

  #   flash[:notice] = "Farewell #{@project.name}, we loved you."

  #   respond_with current_user
  # end

  # def redirect_old_show_route
  #   redirect_to url_for(@project), status: 301
  # end

  # def redirect_to_last
  #   redirect_to url_for(Project.last), status: 302
  # end

  private
#     def initialize_project
# #      @project.images.new# unless @project.images.any?
# #      @project.build_video unless @project.video
#       @project.build_logo unless @project.logo
#       @project.build_cover_image unless @project.cover_image
#     end
  def get_projects
    # TODO: below is SUPER hacky. Would be great to just separate featured projects from the rest
    page = params[:page].try(:to_i) || 1
    per_page = Project.per_page
    @projects = current_tech.projects.indexable_and_external.includes(:respects).where(respects: { respecting_id: current_tech.id, respecting_type: 'Group' }).offset((page - 1) * per_page).limit(per_page)
    if @projects.to_a.size < per_page
      all_featured = current_tech.projects.indexable_and_external.includes(:respects).where(respects: { respecting_id: current_tech.id, respecting_type: 'Group' }).pluck(:id)
      offset = (page - 1) * per_page
      offset -= all_featured.size if @projects.to_a.size == 0
      @projects += current_tech.projects.indexable_and_external.where.not(id: all_featured).offset(offset).limit(per_page - @projects.to_a.size)
    end
    total = current_tech.projects.indexable_and_external.size

    @projects = WillPaginate::Collection.create(page, per_page, total) do |pager|
      pager.replace(@projects.to_a)
    end
  end
end
