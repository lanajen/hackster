class StatsController < ApplicationController
  after_filter :set_cors
  skip_before_filter :store_location_before
  skip_after_filter :store_location_after
  skip_after_filter :track_landing_page, only: [:create]
  protect_from_forgery except: [:legacy, :create]

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

  private
    def set_cors
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Request-Method'] = '*'
    end
end