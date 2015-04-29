class Api::V1::MicrosoftChromeSyncController < Api::V1::BaseController
  skip_before_filter :track_visitor
  skip_after_filter :track_landing_page
  before_filter :load_platform
  before_filter :authenticate

  def show
    render json: ms_sync.attributes
  end

  def update
    changed = ms_sync.update_attributes(params[:chrome])

    render json: { set: changed }, status: :ok
  end

  private
    def authenticate
      return true if Rails.env == 'development'

      authenticate_or_request_with_http_basic do |username, password|
        username == @platform.api_username && password == @platform.api_password
      end
    end

    def load_platform
      @platform = Platform.find_by_user_name! 'microsoft'  # this path is only for them
    end

    def ms_sync
      @ms_sync ||= MicrosoftChromeSync.instance
    end
end