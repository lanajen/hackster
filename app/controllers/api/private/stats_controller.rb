class Api::Private::StatsController < Api::Private::BaseController
  def create
    # because this is called via AJAX on the current page, request.referrer is the page the user requested, and params[:referrer] is the page they were coming from
    if params[:id] and params[:type]
      impressionist_async({ id: params[:id], type: (params[:type]) }, request.referrer, unique: [:session_hash], referrer: params[:referrer], action_name: params[:a], controller_name: params[:c])
    end

    cookies[:landing_page] = request.referrer unless cookies[:landing_page]
    cookies[:initial_referrer] = (params[:referrer].presence || 'unknown') unless cookies[:initial_referrer]

    mark_last_seen! controller: params[:c], action: params[:a], request_url: request.referrer, referrer_url: params[:referrer]

    render status: :ok, nothing: true
  end
end