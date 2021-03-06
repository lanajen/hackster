class UsersController < MainBaseController
  include ScraperUtils

  before_filter :authenticate_user!, only: [:edit, :update, :after_registration, :after_registration_save, :toolbox, :toolbox_save]
  before_filter :load_user, only: [:show, :projects_public, :projects_embed, :projects_drafts, :projects_guest, :projects_respected, :projects_replicated, :toolbox_show, :comments]
  authorize_resource only: [:update, :edit]
  layout :set_layout
  after_action :allow_iframe, only: [:projects_embed]
  protect_from_forgery except: :redirect_to_show
  skip_before_filter :track_visitor, only: [:show, :avatar, :projects_embed]
  skip_after_filter :track_landing_page, only: [:show, :avatar, :projects_embed]

  def index
    title "Browse top community members"
    @users = User.not_admin.invitation_accepted_or_not_invited.publyc.where.not(user_name: nil).where('reputations.points > 15').top.paginate(page: safe_page_params)
  end

  def show
    if user_signed_in?
      impressionist_async @user, "", unique: [:session_hash]  # no need to add :impressionable_type and :impressionable_id, they're already included with @user
    else
      surrogate_keys = [@user.record_key, 'user']
      surrogate_keys << current_platform.user_name if is_whitelabel?
      set_surrogate_key_header *surrogate_keys
      set_cache_control_headers
    end

    title @user.name
    meta_desc "#{@user.name} is on #{site_name}. Come share your hardware projects with #{@user.name} and other hardware makers and developers."

    @public_projects = @user.projects.publyc.own.for_thumb_display.order(made_public_at: :desc, created_at: :desc).limit(3)
    @private_projects = @user.projects.pryvate.for_thumb_display.limit(3)
    @guest_projects = @user.projects.live.guest.for_thumb_display.limit(3)
    @respected_projects = @user.respected_projects.publyc.for_thumb_display.order('respects.created_at DESC').limit(3)
    @replicated_projects = @user.replicated_projects.limit(3)

    @public_query = @user.projects.publyc.own
    @private_query = @user.projects.pryvate
    @guest_query = @user.projects.live.guest
    @respected_query = @user.respected_projects.publyc
    @replicated_query = @user.replicated_projects

    if is_whitelabel?
      @public_query = @public_query.with_group(current_platform, all_moderation_states: true)
      @private_query = @private_query.with_origin_platform(current_platform)
      @guest_query = @guest_query.with_group(current_platform)
      @respected_query = @respected_query.with_group(current_platform)
      @replicated_query = @replicated_query.with_group(current_platform)

      @public_projects = @public_projects.with_group(current_platform, all_moderation_states: true)
      if user_signed_in? and (@user.id == current_user.id or current_user.is?(:admin))
        @private_projects = @private_projects.with_origin_platform(current_platform)

        # projects that were created on this platform but are not linked (= don't have a product)
        ids = @public_query.pluck(:id) + @private_query.pluck(:id)
        @other_projects = @user.projects.publyc.where(origin_platform_id: current_platform.id).where.not(id: ids).for_thumb_display
        @other_count = @other_projects.count
      end
      @respected_projects = @respected_projects.with_group(current_platform)
      @replicated_projects = @replicated_projects.with_group(current_platform)
      @guest_projects = @guest_projects.with_group(current_platform)

      @parts = @user.owned_parts.where(platform_id: current_platform.id).limit(3)
      @parts_count = @user.owned_parts.where(platform_id: current_platform.id).count
    else
      @parts = @user.owned_parts.limit(3)
      @parts_count = @user.owned_parts.count
      @lists = if @user.id == current_user.try(:id) or current_user.try(:is?, :admin)
        @user.lists.order(:full_name)
      else
        @user.lists.publyc.curators_not_hidden.order(:full_name)
      end
    end

    @public_count = @public_query.count
    @private_count = @private_query.count
    @guest_count = @guest_query.count
    @respected_count = @respected_query.count
    @replicated_count = @replicated_query.count
    @other_count ||= 0

    if current_platform
      @comments = @user.live_comments.includes(:commentable).joins("INNER JOIN project_collections ON project_collections.project_id = comments.commentable_id AND commentable_type = 'BaseArticle'").where(project_collections: { collectable_id: current_platform.id, collectable_type: 'Group' }).limit(3)
      @comments_count = @user.live_comments.includes(:commentable).joins("INNER JOIN project_collections ON project_collections.project_id = comments.commentable_id AND commentable_type = 'BaseArticle'").where(project_collections: { collectable_id: current_platform.id, collectable_type: 'Group' }).count
    else
      @comments = @user.live_comments.includes(:commentable).limit(3)
      @comments_count = @user.live_comments.count
    end

    # track_event 'Viewed profile', @user.to_tracker.merge({ own: (current_user.try(:id) == @user.id) })
  end

  def embed
    @user = User.find params[:id]
    @user_link = APP_CONFIG['default_domain'] + '/users/' + @user.user_name
    render layout: 'embed'
  end

  def projects_public
    title "#{@user.name}'s public projects"
    meta_desc "#{@user.name}'s public projects on #{site_name}. Come share your hardware projects with #{@user.name} and other hardware makers and developers."

    @public_projects = @user.projects.publyc.own.for_thumb_display.order(made_public_at: :desc, created_at: :desc)
    if is_whitelabel?
      @public_projects = @public_projects.with_group(current_platform, all_moderation_states: true)
    end
  end

  def projects_embed
    not_found and return if is_whitelabel?

    @projects = @user.projects.publyc.own.for_thumb_display.order(made_public_at: :desc, created_at: :desc)

    surrogate_keys = ["users/#{@user.id}/projects/embed"]
    set_surrogate_key_header *surrogate_keys
    set_cache_control_headers

    params[:sort] = (params[:sort].in?(BaseArticle::SORTING.keys) ? params[:sort] : 'trending')
    if params[:sort]
      @projects = @projects.send(BaseArticle::SORTING[params[:sort]])
    end

    @projects = @projects.paginate(page: safe_page_params)

    @column_width = params[:col_width]
    @column_class = @column_width ? 'no-col' : (params[:col_class] ? CGI.unescape(params[:col_class]) : nil)

    title "#{@user.name}'s hardware projects on Hackster.io"
    render layout: 'embed'
  end

  def projects_drafts
    not_found unless user_signed_in? and (current_user.id == @user.id or current_user.is?(:admin))

    title "#{@user.name}'s private projects"
    meta_desc "#{@user.name}'s private projects on #{site_name}. Come share your hardware projects with #{@user.name} and other hardware makers and developers."

    @private_projects = @user.projects.pryvate.for_thumb_display
    if is_whitelabel?
      @private_projects = @private_projects.with_origin_platform(current_platform)

      # projects that were created on this platform but are not linked (= don't have a product)
      ids = @user.projects.with_origin_platform(current_platform).pluck(:id)
      @other_projects = @user.projects.where(origin_platform_id: current_platform.id).where.not(id: ids).for_thumb_display
    end
  end

  def projects_guest
    title "#{@user.name}'s guest projects"
    meta_desc "#{@user.name}'s guest projects on #{site_name}. Come share your hardware projects with #{@user.name} and other hardware makers and developers."

    @guest_projects = @user.projects.live.guest.for_thumb_display
    if is_whitelabel?
      @guest_projects = @guest_projects.with_group(current_platform)
    end
  end

  def projects_respected
    title "#{@user.name}'s respected projects"
    meta_desc "#{@user.name}'s respected projects on #{site_name}. Come share your hardware projects with #{@user.name} and other hardware makers and developers."

    @respected_projects = @user.respected_projects.publyc.for_thumb_display.order('respects.created_at DESC')
    if is_whitelabel?
      @respected_projects = @respected_projects.with_group(current_platform)
    end
  end

  def projects_replicated
    title "#{@user.name}'s replicated projects"
    meta_desc "#{@user.name}'s replicated projects on #{site_name}. Come share your hardware projects with #{@user.name} and other hardware makers and developers."

    @replicated_projects = @user.replicated_projects
    if is_whitelabel?
      @replicated_projects = @replicated_projects.with_group(current_platform)
    end
  end

  def toolbox_show
    title "#{@user.name}'s toolbox"
    meta_desc "#{@user.name}'s toolbox on #{site_name}. Come share your hardware projects with #{@user.name} and other hardware makers and developers."

    @parts = @user.owned_parts
    if is_whitelabel?
      @parts = @parts.with_platform current_platform.id
    end
  end

  def comments
    title "#{@user.name}'s comments"
    meta_desc "#{@user.name}'s comments on #{site_name}. Come share your hardware projects with #{@user.name} and other hardware makers and developers."

    @comments = if current_platform
      @user.live_comments.includes(:commentable).joins("INNER JOIN project_collections ON project_collections.project_id = comments.commentable_id AND commentable_type = 'BaseArticle'").where(project_collections: { collectable_id: current_platform.id, collectable_type: 'Group' })
    else
      @user.live_comments.includes(:commentable)
    end
  end

  def avatar
    @user = User.find params[:id]

    surrogate_keys = [@user.record_key, 'user/avatar']
    surrogate_keys << current_platform.user_name if is_whitelabel?
    set_surrogate_key_header *surrogate_keys
    set_cache_control_headers 86400

    size = params[:size] || :thumb

    if is_whitelabel? and current_site.enable_custom_avatars?
      link = CustomAvatarHandler.new(@user).fetch(current_site.subdomain)
      if link.blank? or !test_link(link)
        link = if @user.avatar.present?
          @user.decorate.avatar(size, disable_whitelabel: true)
        else
          current_site.default_avatar_url
        end
      end
    else
      link = @user.decorate.avatar(size)
    end

    redirect_to link
  end

  def redirect_to_show
    @user = User.find params[:id]

    respond_to do |format|
      format.html { redirect_to user_path(@user, ref: params[:ref]), status: 301 }
      format.js do
        @projects = if params[:project_ids] and params[:auth_token] and params[:auth_token] == @user.security_token
          ids = params[:project_ids]
          @projects = BaseArticle.where(id: ids.split(','))
        else
          @user.projects.live.for_thumb_display.order(made_public_at: :desc, created_at: :desc)
        end
        @projects = @projects.map do |project|
          project.to_js(private_url: true)
        end.to_json
        render "shared/embed"
      end
    end
  end

  def edit
    @user = current_user
    @user.build_avatar unless @user.avatar
  end

  def update
    @user = current_user

    if @user.update_attributes(params[:user])
      respond_to do |format|
        format.html { redirect_to @user, notice: 'Profile updated.' }

        track_user @user.to_tracker_profile
        track_event 'Updated profile'
      end
    else
      @user.build_avatar unless @user.avatar
      respond_to do |format|
        format.html { render action: 'edit' }
        format.js { render json: { user: @user.errors }, status: :unprocessable_entity }
      end
    end
  end

  def after_registration
    @user = current_user
    @user.build_avatar unless @user.avatar
    # session[:user_return_to] = group_path(@user.groups.first) if @user.groups.any?
  end

  def after_registration_save
    @user = current_user
    if @user.update_attributes(params[:user])
      message = "Profile info saved."
      message += if is_whitelabel?
        " Welcome!"
      else
        # " Now, <a href='/talk' class='alert-link'>come introduce yourself to the community!</a>"
        " Welcome!"
      end
      redirect_to user_toolbox_path, notice: message

      track_user @user.to_tracker_profile
      track_event 'Completed after registration update', {
        completed_avatar: @user.avatar.present?,
        completed_city: @user.city.present?,
        completed_country: @user.country.present?,
        completed_mini_resume: @user.mini_resume.present?,
        completed_name: @user.full_name.present?,
      }
    else
      render action: 'after_registration'
    end
  end

  def toolbox
    current_user.update_attribute :toolbox_shown, true
  end

  def toolbox_save
    redirect_to user_return_to, notice: 'Toolbox saved!'
  end

  private
    def set_layout
      action_name.in?(%w(edit update show projects_public projects_drafts projects_guest projects_respected projects_replicated toolbox_show comments)) ? 'user' : current_layout
    end
end
