class Api::Private::ErrorLogsController < Api::Private::BaseController

  def create
    AppLogger.new(params[:error].to_s, 'error', 'frontend').log_and_notify
    render status: :ok, nothing: true
  end

end