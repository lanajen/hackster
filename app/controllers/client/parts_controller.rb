class Client::PartsController < Client::BaseController
  before_filter :load_platform
  before_filter :load_part, only: [:show, :embed]
  load_resource except: [:index]

  def index
    title "Parts"
    meta_desc "Discover all the parts for #{@platform.name} and their related hardware projects."
    @parts = @platform.parts.paginate(page: safe_page_params)
    render template: 'parts/index'
  end

  def show
    title "#{@platform.name} #{@part.name} projects"
    meta_desc "Discover hardware projects made with #{@platform.name} #{@part.name}."
    @part = @part.decorate
    @projects = @part.projects.paginate(page: safe_page_params)
    render template: 'parts/show'
  end

  def embed
    per_page = begin; [Integer(params[:per_page]), BaseArticle.per_page].min; rescue; BaseArticle.per_page end;  # catches both no and invalid params
    @projects = @part.projects.paginate(per_page: per_page, page: safe_page_params)
    render template: 'parts/embed', layout: 'embed'
  end

  private
    def load_part
      @part = if params[:id]
        Part.find params[:id]
      else
        Part.where(slug: params[:part_slug], platform_id: @platform.id).first!
      end
    end

    def load_platform
      @group = @platform = current_platform
    end
end