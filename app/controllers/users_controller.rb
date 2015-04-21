class UsersController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :index, :redirect_to_show]
  before_filter :load_user, only: [:show]
  authorize_resource except: [:after_registration, :after_registration_save, :redirect_to_show]
  layout :set_layout
  protect_from_forgery except: :redirect_to_show

  def index
    title "Browse top hackers"
    @users = User.invitation_accepted_or_not_invited.where.not(user_name: nil).where('reputations.points > 15').top.paginate(page: safe_page_params)
  end

  def show
    impressionist_async @user, "", unique: [:session_hash]  # no need to add :impressionable_type and :impressionable_id, they're already included with @user
    title @user.name
    meta_desc "#{@user.name} is on #{site_name}. Come share your hardware projects with #{@user.name} and other hardware hackers and makers."

    @public_projects = @user.projects.live.for_thumb_display.order(start_date: :desc, made_public_at: :desc, created_at: :desc)
    @private_projects = @user.projects.private.for_thumb_display
    @respected_projects = @user.respected_projects.indexable_and_external.for_thumb_display
    if current_platform
      @private_projects = if current_user == @user
        @private_projects.select{ |p| (p.platform_tags_cached.map{|t| t.downcase } & current_platform.platform_tags.map{|t| t.name.downcase }).any? }
      else
        @private_projects.with_group(current_platform)
      end
      @public_projects = @public_projects.with_group(current_platform)
      @respected_projects = @respected_projects.with_group(current_platform)
    end

    @comments = if current_platform
      @user.live_comments.includes(:commentable).joins("INNER JOIN project_collections ON project_collections.project_id = comments.commentable_id AND commentable_type = 'Project'").where(project_collections: { collectable_id: current_platform.id, collectable_type: 'Group' })
    else
      @user.live_comments.includes(:commentable)
    end

    # track_event 'Viewed profile', @user.to_tracker.merge({ own: (current_user.try(:id) == @user.id) })
  end

  def redirect_to_show
    @user = User.find params[:id]

    respond_to do |format|
      format.html { redirect_to user_path(@user, ref: params[:ref]), status: 301 }
      format.js do
        @projects = if params[:project_ids] and params[:auth_token] and params[:auth_token] == @user.security_token
          ids = params[:project_ids]
          @projects = Project.where(id: ids.split(','))
        else
          @user.projects.live.for_thumb_display.order(start_date: :desc, made_public_at: :desc, created_at: :desc)
        end
        @projects = @projects.map do |project|
          project.to_js
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

    # copy @user, computes tags_strings first so they're added to the copy
    @user.interest_tags_string
    @user.skill_tags_string
    old_user = @user.dup

    if @user.update_attributes(params[:user])
      respond_to do |format|
        format.html { redirect_to @user, notice: 'Profile updated.' }
        format.js do
          @user = @user.decorate
          if old_user.interest_tags_string != @user.interest_tags_string or old_user.skill_tags_string != @user.skill_tags_string or old_user.user_name != @user.user_name
            @refresh = true
          end
        end

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
      if @user.projects.any?
        redirect_to @user.projects.first, notice: "Profile info saved! Now you can start working on your project."
      else
        redirect_to user_return_to, notice: 'Profile info saved!'
      end

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

  private
    def set_layout
      action_name.in?(%w(edit update show)) ? 'user' : current_layout
    end
end