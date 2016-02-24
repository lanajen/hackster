class Api::V1::PlatformsController < Api::V1::BaseController
  include PlatformHelper
  before_filter :load_platform, only: [:show]
  before_filter :load_projects, only: [:show]

  # def index
  #   render json: Platform.order(full_name: :asc)
  # end

  def show
    set_surrogate_key_header "api/platforms/#{@platform.id}/projects"
    set_cache_control_headers 3600
  end

  private
    def load_platform
      @platform = Platform.find_by_user_name! params[:user_name]
    end
end