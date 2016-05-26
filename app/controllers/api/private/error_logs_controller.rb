class Api::Private::ErrorLogsController < Api::Private::BaseController
  def create
    AppLogger.new(params[:error].to_s, 'error', 'frontend').create_log
    render status: :ok, nothing: true
  end
end