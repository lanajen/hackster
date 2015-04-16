class Api::V1::PlatformsController < Api::V1::BaseController
  include PlatformHelper
  # before_filter :public_api_methods, only: [:index, :show]
  before_filter :load_platform, only: [:show]
  before_filter :load_projects, only: [:show]

  def index
    render json: Platform.order(full_name: :asc)
  end

  def show
    render json: { platform: { name: @platform.name, url: platform_home_url(@platform) }, projects: @projects.map{|c| project = c.project; { name: project.name, url: project_url(project), embed_url: project_embed_url(project), cover_image_url: project.cover_image.try(:file_url, :cover_thumb), one_liner: project.one_liner, author_names: project.users.map(&:name).to_sentence, views: project.impressions_count, comments: project.comments_count, respects: project.respects_count } } }
  end

  private

    def load_platform
      @platform = Platform.find_by_user_name! params[:user_name]
    end
end