class Api::Private::StatsController < Api::Private::BaseController

  def create
    impressionist_async({ id: params[:id], type: (params[:type]) }, request.referrer, unique: [:session_hash], referrer: params[:referrer], action_name: params[:a], controller_name: params[:c])

    cookies[:landing_page] = request.referrer unless cookies[:landing_page]
    cookies[:initial_referrer] = (params[:referrer].presence || 'unknown') unless cookies[:initial_referrer]

    render status: :ok, nothing: true
  end
end