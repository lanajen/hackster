class StatsController < ApplicationController
  skip_after_filter :track_landing_page, only: [:create]
  protect_from_forgery except: [:create]

  def create
    impressionist_async({ id: params[:id], type: (params[:type]) }, request.referrer, unique: [:session_hash], referrer: params[:referrer], action_name: params[:a], controller_name: params[:c])

    cookies[:landing_page] = request.referrer unless cookies[:landing_page]
    cookies[:initial_referrer] = (params[:referrer].presence || 'unknown') unless cookies[:initial_referrer]

    render status: :ok, nothing: true
  end

  def legacy
    impressionist_async({ id: params[:id], type: 'Project' }, request.referrer, unique: [:session_hash], action_name: 'show', controller_name: 'projects')

    cookies[:landing_page] = request.referrer unless cookies[:landing_page]
    cookies[:initial_referrer] = (params[:referrer].presence || 'unknown') unless cookies[:initial_referrer]

    render status: :ok, nothing: true
  end
end