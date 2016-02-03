class Api::V1::ChromeSyncController < Api::V1::BaseController
  before_filter :authenticate_api_user

  def show
    render json: chrome_sync.attributes(params[:locale])
  end

  def update
    changed = chrome_sync.update_attributes(params[:chrome], params[:locale])

    render json: { set: changed }, status: :ok
  end

  private
    def chrome_sync
      @chrome_sync ||= ChromeSync::Base.new(current_platform.user_name)
    end
end