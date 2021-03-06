class HackerSpacesController < MainBaseController
  before_filter :authenticate_user!, only: [:edit, :update]
  before_filter :load_hacker_space, only: [:show, :redirect_to_show, :update]
  layout 'group_shared', only: [:show]
  respond_to :html

  def index
    title 'Hacker spaces around the world'
    @hacker_spaces = HackerSpaceDecorator.decorate_collection(HackerSpace.publyc.includes(:avatar).order(:full_name))
    @markers_hash = Rails.cache.fetch(['hackerspaces', 'markers']) do
      Gmaps4rails.build_markers(@hacker_spaces) do |space, marker|
        marker.lat space.latitude
        marker.lng space.longitude
        marker.infowindow "<a href='#{hacker_space_path(space)}'>#{space.name}</a>"
      end
    end

    render "groups/hacker_spaces/#{self.action_name}"
  end

  def show
    title @hacker_space.name
    meta_desc "Join the hacker space #{@hacker_space.name} on Hackster.io!"

    @projects = @hacker_space.project_collections.visible.joins(:project).merge(BaseArticle.for_thumb_display_in_collection.order(created_at: :desc)).paginate(page: safe_page_params)

    @members = @hacker_space.members.includes(:user).includes(user: :avatar).invitation_accepted_or_not_invited.with_group_roles('member').map(&:user).select{|u| u.invitation_token.nil? }
    @team_members = @hacker_space.members.includes(:user).includes(user: :avatar).invitation_accepted_or_not_invited.with_group_roles('team').map(&:user).select{|u| u.invitation_token.nil? }
    # @assignments = @hacker_space.assignments

    render "groups/shared/#{self.action_name}"
  end

  def redirect_to_show
    redirect_to hacker_space_path(@hacker_space)
  end

  def new
    authorize! :create, HackerSpace
    title "Create a new hacker space"
    meta_desc "Add your hacker space to Hackster and tens of thousands of hardware developers and makers around the world."
    @hacker_space = HackerSpace.new

    render "groups/hacker_spaces/#{self.action_name}"
  end

  def create
    @hacker_space = HackerSpace.new(params[:group])
    authorize! :create, @hacker_space

    if user_signed_in?
      admin = @hacker_space.members.new user_id: current_user.id, group_roles: ['team']
    else
      @hacker_space.require_admin_email = true
    end

    if @hacker_space.valid?
      if user_signed_in?
        @hacker_space.save
        admin.update_attribute :permission_action, 'manage'
        redirect_to @hacker_space, notice: "Welcome to the new hub for #{@hacker_space.name}!"
      else
        redirect_to create__simplified_registrations_path(user: { email: @hacker_space.admin_email }, redirect_to: create_hacker_spaces_path(group: params[:group]))
      end
    else
      render "groups/hacker_spaces/new"
    end
  end

  def update
    authorize! :update, @hacker_space
    old_hacker_space = @hacker_space.dup

    if @hacker_space.update_attributes(params[:group])
      respond_to do |format|
        format.html { redirect_to @hacker_space, notice: 'Profile updated.' }
        format.js do
          @hacker_space = @hacker_space.decorate
          if old_hacker_space.user_name != @hacker_space.user_name
            @refresh = true
          end

          render "groups/hacker_spaces/#{self.action_name}"
        end

        track_event 'Updated hacker space'
      end
    else
      @hacker_space.build_avatar unless @hacker_space.avatar
      respond_to do |format|
        format.html { render 'groups/shared/edit' }
        format.js { render json: { group: @hacker_space.errors }, status: :unprocessable_entity }
      end
    end
  end

  private
    def load_hacker_space
      @group = @hacker_space = HackerSpace.where("LOWER(groups.user_name) = ?", params[:user_name].downcase).first!
    end
end