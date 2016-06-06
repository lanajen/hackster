class PartsController < MainBaseController
  before_filter :load_platform_with_slug
  before_filter :load_part, only: [:show, :embed]
  load_resource except: [:index]
  layout 'platform'

  def index
    @page_title = @platform.parts_text
    title @page_title
    meta_desc "Discover all the #{@platform.parts_text.sub(/^[A-Z]/) {|f| f.downcase }} and their related hardware projects."
    @parts = @platform.parts.visible.default_sort.paginate(page: safe_page_params)
    @challenge = @platform.active_challenge ? @platform.challenges.active.first : nil
  end

  def sub_index
    @page_title = "Products based on #{@platform.name}'s technology"
    title @page_title
    meta_desc "Discover all the products based on #{@platform.name}'s technology and their related hardware projects."
    @parts = @platform.sub_parts.paginate(page: safe_page_params)

    render 'index'
  end

  def show
    impressionist_async @part, "", unique: [:session_hash]

    @meta_desc = if @part.projects_count > 0
      "#{ActionController::Base.helpers.pluralize @part.projects_count, 'hardware project'} made with #{@part.name} from #{@platform.name}."
    else
      "Share your hardware projects made with #{@part.name} from #{@platform.name}."
    end
    meta_desc @meta_desc

    params[:sort] = (params[:sort].in?(Project::SORTING.keys) ? params[:sort] : 'trending')
    @by = (params[:by].in?(Project::FILTERS.keys) ? params[:by] : 'all')


    @projects = @part.projects

    @projects = params[:show_all] ? @projects.published : @projects.indexable

    if @by and @by.in? Project::FILTERS.keys
      @projects = @projects.send(Project::FILTERS[@by], user: current_user, show_all: params[:show_all])
      @by = case @by
      when '7days'
        '7 days of'
      when '30days'
        '30 days of'
      when '1year'
        '12 months of'
      else
        @by
      end
    end

    if params[:sort]
      @projects = @projects.send(Project::SORTING[params[:sort]], show_all: params[:show_all])
    end

    if params[:difficulty].try(:to_sym).in? Project::DIFFICULTIES.values
      @projects = @projects.where(difficulty: params[:difficulty])
    end

    if params[:type].try(:to_sym).in? Project.content_types(%w(Project)).values
      @projects = @projects.with_type(params[:type])
    end

    respond_to do |format|
      format.html do
        title "#{@part.full_name} projects"
        @projects = @projects.for_thumb_display.paginate(page: safe_page_params)
        @part = @part.decorate
        @challenge = @platform.active_challenge ? @platform.challenges.active.first : nil
      end
      format.rss { redirect_to part_path(@part, format: :atom), status: :moved_permanently }
      format.atom do
        title "Latest #{@part.full_name} projects"
        @projects = @projects.last_featured.limit(10)
        render 'projects/index', layout: false
      end
    end
  end

  def embed
    per_page = begin; [Integer(params[:per_page]), BaseArticle.per_page].min; rescue; BaseArticle.per_page end;  # catches both no and invalid params
    @projects = @part.projects.publyc.paginate(per_page: per_page, page: safe_page_params)
    render layout: 'embed'
  end

  private
    def load_part
      @part = if params[:id]
        Part.find params[:id]
      else
        Part.where(slug: params[:part_slug], platform_id: @platform.id).first!
      end
    end

    def load_platform_with_slug
      @group = @platform = load_with_slug
      authorize! :read, @platform
    end
end