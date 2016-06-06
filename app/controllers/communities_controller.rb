class CommunitiesController < MainBaseController
  before_filter :authenticate_user!, only: [:edit, :update]
  before_filter :load_community, only: [:show, :redirect_to_show, :update]
  layout 'group_shared', only: [:show]
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

    @projects = @community.project_collections.visible.joins(:project).merge(BaseArticle.for_thumb_display_in_collection.order(created_at: :desc)).paginate(page: safe_page_params)
    @members = @community.members.invitation_accepted_or_not_invited.with_group_roles('member').map(&:user).select{|u| u.invitation_token.nil? }

    render "groups/shared/show"
  end

  def redirect_to_show
    redirect_to community_path(@community)
  end


  def new
    title "Create a new community"
    meta_desc "Add your community to Hackster and tens of thousands of hardware developers and makers."
    @community = Community.new
    authorize! :create, @community

    render "groups/communities/#{self.action_name}"
  end

  def create
    @community = Community.new params[:group]
    authorize! :create, @community

    if user_signed_in?
      admin = @community.members.new user_id: current_user.id
    else
      @community.require_admin_email = true
    end

    if @community.valid?
      if user_signed_in?
        @community.save
        admin.update_attribute :permission_action, 'manage'
        redirect_to @community, notice: "Welcome to the new hub for #{@community.name}!"
      else
        redirect_to create__simplified_registrations_path(user: { email: @community.admin_email }, redirect_to: create_communities_path(group: params[:group]))
      end
    else
      render 'groups/communities/new'
    end
  end

  def update
    authorize! :update, @community
    old_community = @community.dup

    if @community.update_attributes(params[:group])
      respond_to do |format|
        format.html { redirect_to @community, notice: 'Profile updated.' }

        track_event 'Updated community'
      end
    else
      @community.build_avatar unless @community.avatar
      respond_to do |format|
        format.html { render "groups/shared/edit" }
        format.js { render json: { group: @community.errors }, status: :unprocessable_entity }
      end
    end
  end

  private
    def load_community
      @group = @community = Community.where(type: 'Community').find_by_user_name! params[:user_name].downcase
    end
end