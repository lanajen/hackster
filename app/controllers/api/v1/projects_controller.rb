class Api::V1::ProjectsController < Api::V1::BaseController
  before_filter :authenticate_user!, only: [:create, :update, :destroy]
  load_and_authorize_resource only: [:create, :update, :destroy]
  # before_filter :public_api_methods, only: [:index, :show]

  def index
    params[:sort] = (params[:sort].in?(Project::SORTING.keys) ? params[:sort] : 'trending')
    by = (params[:by].in?(Project::FILTERS.keys) ? params[:by] : 'all')

    projects = Project.indexable.for_thumb_display
    if params[:sort]
      projects = projects.send(Project::SORTING[params[:sort]])
    end

    if by and by.in? Project::FILTERS.keys
      projects = projects.send(Project::FILTERS[by])
    end

    projects = projects.paginate(page: safe_page_params)

    render json: projects
  end

  def show
    project = Project.find params[:id]
    render json: project
  end

  def create
    if project.save
      render json: project, status: :ok
    else
      render json: project.errors, status: :unprocessable_entity
    end
  end

  def update
    @panel = params[:panel]

    # hack to clear up widgets that have somehow been deleted and that prevent all thing from being saved
    if params[:project].try(:[], :widgets_attributes)
      widgets = {}
      params[:project][:widgets_attributes].each do |i, widget|
        widgets[i] = widget if widget['id'].present?
      end
      all = Widget.where(id: widgets.values.map{|v| v['id'] }).pluck(:id).map{|i| i.to_s }
      widgets.each do |i, widget|
        unless all.include? widget['id']
          params[:project][:widgets_attributes].delete(i)
        end
      end
    end

    if (params[:save].present? and params[:save] == '0') or @project.update_attributes params[:project]
      if @panel.in? %w(hardware publish team software)
        render 'projects/forms/update'
      else
        render 'projects/forms/checklist', status: :ok
      end
    else
      message = "Couldn't save project: #{@project.inspect} // user: #{current_user.user_name} // params: #{params.inspect} // errors: #{@project.errors.inspect}"
      log_line = LogLine.create(message: message, log_type: '422', source: 'api/projects')
      NotificationCenter.notify_via_email nil, :log_line, log_line.id, 'error_notification' if ENV['ENABLE_ERROR_NOTIF']
      render json: { project: @project.errors }, status: :unprocessable_entity
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

  def video_data
    data = params[:videoData]
    link = data[:link]
    service = data[:service]

    open(link, "Access-Control-Allow-Origin" => "*", ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE) do |f|
      case service 
      when 'vimeo'
        body = JSON.parse(f.read)[0]
        base64prefix = 'data:image/jpeg;base64,'
        uri = Base64.strict_encode64(open(body['thumbnail_large'], ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read)
        render json: { poster: base64prefix + uri }
      when 'youtube'
        body = f.read
        base64prefix = 'data:' + f.content_type + ';base64,'
        uri = Base64.strict_encode64(body)
        render json: { poster: base64prefix + uri }
      when 'vine'
        body = JSON.parse(f.read)
        base64prefix = 'data:image/jpeg;base64,'
        uri = Base64.strict_encode64(open(body['thumbnail_url'], ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read)
        render json: { poster: base64prefix + uri }
      else
        render json: project.errors, status: :unprocessable_entity
      end
    end
  end

  def description
    project = Project.find params[:id]

    if project.story_json == nil and project.description != nil
      render json: { story: nil, description: project.decorate.description }
    elsif project.story_json != nil
      render json: { story: project.story_json, description: nil }
    else
      render json: { story: [], description: nil }
    end
  end

end
