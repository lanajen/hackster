class StatsController < ApplicationController
  include GraphHelper

  before_filter :authenticate_user!, only: [:index]
  after_filter :set_cors, only: [:create, :legacy]
  skip_before_filter :store_location_before, only: [:create, :legacy]
  skip_after_filter :store_location_after, only: [:create, :legacy]
  skip_after_filter :track_landing_page, only: [:create, :legacy]
  protect_from_forgery except: [:legacy, :create]

  def index
    @user = ((params[:user_id] and current_user.is?(:admin)) ? User.find(params[:user_id]) : current_user)

    @reputation_this_month = @user.reputation_events.where("reputation_events.event_date > ?", Date.today.beginning_of_month).sum(:points)

    sql = "SELECT to_char(event_date, 'yyyy-mm') as date, COUNT(*) as count FROM reputation_events WHERE date_part('months', now() - reputation_events.event_date) < 12 AND reputation_events.user_id = %i GROUP BY date ORDER BY date;"
    @reputation_points = graph_with_dates_for sql % @user.id, 'Reputation', 'ColumnChart', 0, 'month', (@user.invitation_accepted_at || @user.created_at)

    @new_followers = @user.followers.where("follow_relations.created_at > ?", Date.today.beginning_of_month).count
    @new_views = @user.impressions.where("impressions.created_at > ?", Date.today.beginning_of_month).count
    @new_respects = Respect.where(respectable_type: 'Project', respectable_id: @user.projects.pluck(:id)).where("respects.created_at > ?", Date.today.beginning_of_month).count
    @new_project_views = Impression.where(impressionable_type: 'Project', impressionable_id: @user.projects.pluck(:id)).where("impressions.created_at > ?", Date.today.beginning_of_month).count

    @reputation_events = @user.reputation_events.order(event_date: :desc) if current_user.is? :admin
  end

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