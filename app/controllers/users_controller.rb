class UsersController < ApplicationController
  before_filter :authenticate_user!, only: [:edit, :update, :after_registration, :after_registration_save, :toolbox, :toolbox_save]
  before_filter :load_user, only: [:show, :projects_public, :projects_drafts, :projects_guest, :projects_respected, :projects_replicated, :toolbox_show, :comments]
  authorize_resource only: [:update, :edit]
  layout :set_layout
  protect_from_forgery except: :redirect_to_show
  skip_before_filter :track_visitor, only: [:show]
  skip_after_filter :track_landing_page, only: [:show]

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

    @public_projects = @user.projects.publyc.own.for_thumb_display.order(start_date: :desc, made_public_at: :desc, created_at: :desc).limit(3)
    @private_projects = @user.projects.pryvate.for_thumb_display.limit(3)
    @guest_projects = @user.projects.live.guest.for_thumb_display.limit(3)
    @respected_projects = @user.respected_projects.indexable_and_external.for_thumb_display.order('respects.created_at DESC').limit(3)
    @replicated_projects = @user.replicated_projects.limit(3)

    @public_query = @user.projects.publyc.own
    @private_query = @user.projects.pryvate
    @guest_query = @user.projects.live.guest
    @respected_query = @user.respected_projects.indexable_and_external
    @replicated_query = @user.replicated_projects

    if is_whitelabel?
      @private_projects = if current_user == @user
        @private_projects.select{ |p| (p.platform_tags_cached.map{|t| t.downcase } & current_platform.platform_tags.map{|t| t.name.downcase }).any? }
      else
        @private_projects.with_group(current_platform)
      end
      @public_projects = @public_projects.with_group(current_platform)
      @public_count = @public_projects.count
      @respected_projects = @respected_projects.with_group(current_platform)
      @replicated_projects = @replicated_projects.with_group(current_platform)
      if @user == current_user and !current_site.hide_alternate_search_results
        ids = @user.projects.with_group(current_platform).pluck(:id)
        @other_projects = @user.projects.where.not(id: ids).for_thumb_display
        @public_count += @other_projects.count
      end

      @public_query = @public_query.with_group(current_platform)
      @private_query = @private_query.with_group(current_platform)
      @guest_query = @guest_query.with_group(current_platform)
      @respected_query = @respected_query.with_group(current_platform)
    else
      @parts = @user.owned_parts.limit(3)
      @parts_count = @user.owned_parts.count
      @lists = if @user.id == current_user.try(:id) or current_user.try(:is?, :admin)
        @user.lists.order(:full_name)
      else
        @user.lists.publyc.order(:full_name)
      end
    end

    @public_count = @public_query.count
    @private_count = @private_query.count
    @guest_count = @guest_query.count
    @respected_count = @respected_query.count
    @replicated_count = @replicated_query.count

    if current_platform
      @comments = @user.live_comments.includes(:commentable).joins("INNER JOIN project_collections ON project_collections.project_id = comments.commentable_id AND commentable_type = 'BaseArticle'").where(project_collections: { collectable_id: current_platform.id, collectable_type: 'Group' }).limit(3)
      @comments_count = @user.live_comments.includes(:commentable).joins("INNER JOIN project_collections ON project_collections.project_id = comments.commentable_id AND commentable_type = 'BaseArticle'").where(project_collections: { collectable_id: current_platform.id, collectable_type: 'Group' }).count
    else
      @comments = @user.live_comments.includes(:commentable).limit(3)
      @comments_count = @user.live_comments.count
    end

    # track_event 'Viewed profile', @user.to_tracker.merge({ own: (current_user.try(:id) == @user.id) })
  end

  def projects_public
    title "#{@user.name}'s public projects"
    meta_desc "#{@user.name}'s public projects on #{site_name}. Come share your hardware projects with #{@user.name} and other hardware makers and developers."

    @public_projects = @user.projects.publyc.own.for_thumb_display.order(start_date: :desc, made_public_at: :desc, created_at: :desc)
    if is_whitelabel?
      @public_projects = @public_projects.with_group(current_platform)
    end
  end

  def projects_drafts
    not_found unless user_signed_in? and (current_user.id == @user.id or current_user.is?(:admin))

    title "#{@user.name}'s private projects"
    meta_desc "#{@user.name}'s private projects on #{site_name}. Come share your hardware projects with #{@user.name} and other hardware makers and developers."

    @private_projects = @user.projects.pryvate.for_thumb_display
    if is_whitelabel?
      @private_projects = if current_user == @user
        @private_projects.select{ |p| (p.platform_tags_cached.map{|t| t.downcase } & current_platform.platform_tags.map{|t| t.name.downcase }).any? }
      else
        @private_projects.with_group(current_platform)
      end
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

    @respected_projects = @user.respected_projects.indexable_and_external.for_thumb_display.order('respects.created_at DESC')
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
    not_found if is_whitelabel?

    title "#{@user.name}'s toolbox"
    meta_desc "#{@user.name}'s toolbox on #{site_name}. Come share your hardware projects with #{@user.name} and other hardware makers and developers."

    @parts = @user.owned_parts
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

  def redirect_to_show
    @user = User.find params[:id]

    respond_to do |format|
      format.html { redirect_to user_path(@user, ref: params[:ref]), status: 301 }
      format.js do
        @projects = if params[:project_ids] and params[:auth_token] and params[:auth_token] == @user.security_token
          ids = params[:project_ids]
          @projects = BaseArticle.where(id: ids.split(','))
        else
          @user.projects.live.for_thumb_display.order(start_date: :desc, made_public_at: :desc, created_at: :desc)
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