class HackerSpacesController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :redirect_to_show, :index]
  before_filter :load_hacker_space, only: [:show, :redirect_to_show, :update]
  layout 'hacker_space', only: [:edit, :update, :show]
  respond_to :html

  def index
    title 'Hacker spaces around the world'
    @hacker_spaces = HackerSpaceDecorator.decorate_collection(HackerSpace.public.includes(:avatar).order(:full_name))
    @hash = Gmaps4rails.build_markers(@hacker_spaces) do |space, marker|
      marker.lat space.latitude
      marker.lng space.longitude
      marker.infowindow "<a href='#{hacker_space_path(space)}'>#{space.name}</a>"
    end

    render "groups/hacker_spaces/#{self.action_name}"
  end

  def show
    title @hacker_space.name
    meta_desc "Join the hacker space #{@hacker_space.name} on Hackster.io!"
    # @broadcasts = @hacker_space.broadcasts.limit 20
    @projects = @hacker_space.projects.public.order(collection_id: :desc).paginate(page: safe_page_params, per_page: 16)
    @members = @hacker_space.members.invitation_accepted_or_not_invited.with_group_roles('member').map(&:user).select{|u| u.invitation_token.nil? }
    @team_members = @hacker_space.members.invitation_accepted_or_not_invited.with_group_roles('team').map(&:user).select{|u| u.invitation_token.nil? }
    # @assignments = @hacker_space.assignments

    render "groups/hacker_spaces/#{self.action_name}"
  end

  def redirect_to_show
    redirect_to hacker_space_path(@hacker_space)
  end

  def new
    authorize! :create, HackerSpace
    title "Create a new hacker space"
    @hacker_space = HackerSpace.new

    render "groups/hacker_spaces/#{self.action_name}"
  end

  def create
    @hacker_space = HackerSpace.new(params[:hacker_space])
    authorize! :create, @hacker_space

    admin = @hacker_space.members.new(user_id: current_user.id)
    @hacker_space.private = true

    if @hacker_space.save
      admin.update_attribute :permission_action, 'manage'
      flash[:notice] = "Welcome to #{@hacker_space.class.name} #{@hacker_space.name}!"
      respond_with @hacker_space
    else
      render "groups/hacker_spaces/new"
    end
  end

  def edit
    @hacker_space = HackerSpace.find(params[:id])
    authorize! :update, @hacker_space
    @hacker_space.build_avatar unless @hacker_space.avatar

    render "groups/hacker_spaces/#{self.action_name}"
  end

  def update
    authorize! :update, @hacker_space
    old_hacker_space = @hacker_space.dup

    if @hacker_space.update_attributes(params[:group])
      respond_to do |format|
        format.html { redirect_to @hacker_space, notice: 'Profile updated.' }
        format.js do
          @hacker_space.avatar = nil unless @hacker_space.avatar.try(:file_url)
          @hacker_space = @hacker_space.decorate
          # if old_hacker_space.interest_tags_string != @hacker_space.interest_tags_string or old_hacker_space.skill_tags_string != @hacker_space.skill_tags_string
          #   @refresh = true
          # end

          render "groups/hacker_spaces/#{self.action_name}"
        end

        track_event 'Updated hacker space'
      end
    else
      @hacker_space.build_avatar unless @hacker_space.avatar
      respond_to do |format|
        format.html { render action: 'edit' }
        format.js { render json: { group: @hacker_space.errors }, status: :unprocessable_entity }
      end
    end
  end

  private
    def load_hacker_space
      @hacker_space = HackerSpace.find_by_user_name! params[:user_name]
    end
end