class Api::V1::ProjectsController < Api::V1::BaseController
  before_filter :public_api_methods, only: [:index, :show]
  before_filter :authenticate_user!, only: [:create, :update, :destroy]
  before_filter :load_and_authorize_resource, only: [:create, :update, :destroy]

  def index
    params[:sort] = (params[:sort].in?(BaseArticle::SORTING.keys) ? params[:sort] : 'trending')
    by = (params[:by].in?(BaseArticle::FILTERS.keys) ? params[:by] : 'all')

    projects = if params[:platform_user_name]
      parent = Platform.find_by_user_name! params[:platform_user_name]
      if params[:part_mpn]
        parent = parent.parts.find_by_mpn! params[:part_mpn]
      end
      parent.projects
    else
      BaseArticle
    end

    projects = projects.indexable.for_thumb_display

    if params[:sort]
      projects = projects.send(BaseArticle::SORTING[params[:sort]])
    end

    if by and by.in? BaseArticle::FILTERS.keys
      projects = projects.send(BaseArticle::FILTERS[by])
    end

    @projects = projects.paginate(page: safe_page_params)
  end

  def show
    @project = BaseArticle.where(id: params[:id]).public.first!
  end

  def create
    if project.save
      render status: :ok, nothing: true
    else
      render json: project.errors, status: :unprocessable_entity
    end
  end

  def update
    @panel = params[:panel]

    # hack to clear up widgets that have somehow been deleted and that prevent all thing from being saved
    if params[:base_article].try(:[], :widgets_attributes)
      widgets = {}
      params[:base_article][:widgets_attributes].each do |i, widget|
        widgets[i] = widget if widget['id'].present?
      end
      all = Widget.where(id: widgets.values.map{|v| v['id'] }).pluck(:id).map{|i| i.to_s }
      widgets.each do |i, widget|
        unless all.include? widget['id']
          params[:base_article][:widgets_attributes].delete(i)
        end
      end
    end

    if (params[:save].present? and params[:save] == '0') or @project.update_attributes params[:base_article]
      if @panel.in? %w(hardware publish team software protip_attachments protip_parts)
        render 'projects/forms/update'
      else
        render 'projects/forms/checklist', status: :ok
      end
    else
      message = "Couldn't save project: #{@project.inspect} // user: #{current_user.user_name} // params: #{params.inspect} // errors: #{@project.errors.inspect}"
      log_line = LogLine.create(message: message, log_type: '422', source: 'api/projects')
      # NotificationCenter.notify_via_email nil, :log_line, log_line.id, 'error_notification' if ENV['ENABLE_ERROR_NOTIF']
      render json: { base_article: @project.errors }, status: :unprocessable_entity
    end
  rescue => e
    message = "Couldn't save project: #{@project.inspect} // user: #{current_user.try(:user_name)} // params: #{params.inspect} // exception: #{e.inspect}"
    log_line = LogLine.create(message: message, log_type: '5xx', source: 'api/projects')
    NotificationCenter.notify_via_email nil, :log_line, log_line.id, 'error_notification' if ENV['ENABLE_ERROR_NOTIF']
    render status: :internal_server_error, nothing: true
    raise e if Rails.env.development?
  end

  def destroy
    project.destroy

    render status: :ok, nothing: true
  end

  def description
    project = Project.find params[:id]

    if project.story_json.nil? && !project.description.nil?
      render json: { description: project.decorate.description, story: nil }
    elsif !project.story_json.nil?
      # do the same for file.
      story = project.story_json.map do |c|
        if c['type'] == 'Carousel'
          c['images'] = c['images'].map do |i|
            i['url'] = Image.find(i['id']).decorate.file_url
            i
          end
          c
        elsif c['type'] == 'File'
          c['data']['url'] = Attachment.find(c['data']['id']).file_url
          c
        else 
          c
        end
      end
      render json: { description: nil, story: story.to_json }
    else
      render json: { description: '', story: nil }
    end
  end

  private
    def load_and_authorize_resource
      @project = BaseArticle.find params[:project_id] || params[:id]
      authorize! self.action_name, @project
    end
end
