class CommunitiesController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :redirect_to_show, :index]
  before_filter :load_community, only: [:show, :redirect_to_show, :update]
  layout 'community', only: [:edit, :update, :show]
  respond_to :html

  def index
    title 'Hacker communities'
    @communities = Community.where(id: %w(2156 2158))
    @hackathons = Event.where(id: %w(346 353))
    @promotions = Promotion.where(id: %w(139 181))

    render "groups/communities/#{self.action_name}"
  end

  def show
    title @community.name
    meta_desc "Join the community #{@community.name} on Hackster.io!"
    # @broadcasts = @community.broadcasts.limit 20
    @projects = @community.projects.public.order(created_at: :desc).paginate(page: safe_page_params, per_page: 16)
    @members = @community.members.invitation_accepted_or_not_invited.with_group_roles('member').map(&:user).select{|u| u.invitation_token.nil? }
    # @team_members = @community.members.invitation_accepted_or_not_invited.with_group_roles('team').map(&:user).select{|u| u.invitation_token.nil? }
    # @assignments = @community.assignments

    render "groups/communities/#{self.action_name}"
  end

  def redirect_to_show
    redirect_to community_path(@community)
  end

  def new
    authorize! :create, Community
    title "Create a new community"
    @community = Community.new

    render "groups/communities/#{self.action_name}"
  end

  def create
    @community = Community.new(params[:group])
    authorize! :create, @community

    admin = @community.members.new(user_id: current_user.id)
    @community.private = true

    if @community.save
      admin.update_attribute :permission_action, 'manage'
      flash[:notice] = "Welcome to #{@community.class.name} #{@community.name}!"
      respond_with @community
    else
      render "groups/communities/new"
    end
  end

  def edit
    @community = Community.find(params[:id])
    authorize! :update, @community
    @community.build_avatar unless @community.avatar

    render "groups/communities/#{self.action_name}"
  end

  def update
    authorize! :update, @community
    old_community = @community.dup

    if @community.update_attributes(params[:group])
      respond_to do |format|
        format.html { redirect_to @community, notice: 'Profile updated.' }
        format.js do
          @community = @community.decorate
          if old_community.user_name != @community.user_name
            @refresh = true
          end

          render "groups/communities/#{self.action_name}"
        end

        track_event 'Updated community'
      end
    else
      @community.build_avatar unless @community.avatar
      respond_to do |format|
        format.html { render action: 'edit' }
        format.js { render json: { group: @community.errors }, status: :unprocessable_entity }
      end
    end
  end

  private
    def load_community
      @group = @community = Community.where(type: 'Community').find_by_user_name! params[:user_name]
    end
end