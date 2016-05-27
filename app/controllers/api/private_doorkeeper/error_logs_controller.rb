class Api::PrivateDoorkeeper::ErrorLogsController < Api::PrivateDoorkeeper::BaseController
  before_action :doorkeeper_authorize_without_scope!

  def create
    AppLogger.new(params[:error].to_s, 'error', 'frontend').create_log
    render status: :ok, nothing: true
  end
end