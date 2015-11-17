class Api::V1::MicrosoftChromeSyncController < Api::V1::BaseController
  skip_before_filter :track_visitor
  skip_after_filter :track_landing_page
  skip_before_filter :authorize_access!
  before_filter :authenticate_api_user

  def show
    render json: ms_sync.attributes(params[:locale])
  end

  def update
    changed = ms_sync.update_attributes(params[:chrome], params[:locale])

    render json: { set: changed }, status: :ok
  end

  private
    def load_platform username
      @platform = Platform.find_by_user_name! 'microsoft'  # this path is only for them
    end

    def ms_sync
      @ms_sync ||= MicrosoftChromeSync.instance
    end
end