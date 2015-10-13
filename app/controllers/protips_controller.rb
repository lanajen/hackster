class ProtipsController < ApplicationController
  before_filter :load_project_with_hid, only: [:show, :update]
  before_filter :ensure_belongs_to_platform, only: [:show, :update]
  respond_to :html
  skip_before_filter :track_visitor, only: [:show]
  skip_after_filter :track_landing_page, only: [:show]

  def show
    authorize! :read, @project unless params[:auth_token] and params[:auth_token] == @project.security_token

    if user_signed_in?
      impressionist_async @project, '', unique: [:session_hash]
    else
      surrogate_keys = [@project.record_key, 'project']
      surrogate_keys << current_platform.user_name if is_whitelabel?
      set_surrogate_key_header *surrogate_keys
      set_cache_control_headers
    end

    @can_edit = (user_signed_in? and current_user.can? :edit, @project)

    title @project.name
    @project_meta_desc = "#{@project.one_liner.try(:gsub, /\.$/, '')}. Find this and other hardware protips on Hackster.io."
    meta_desc @project_meta_desc
    @project = ProtipDecorator.decorate(@project)

    @parts = @project.parts.alphabetical.includes(:image)

    # @other_projects = SimilarProjectsFinder.new(@project).results.for_thumb_display
    # @other_projects = @other_projects.with_group current_platform if is_whitelabel?

    @author = @project.users.includes(:avatar).first.decorate

    # if @project.public?
    #   @respecting_users = @project.respecting_users.includes(:avatar).where.not(users: { full_name: nil }).limit(8)
    #   if is_whitelabel?
    #     @respecting_users = @respecting_users.where(users: { enable_sharing: true })
    #   end
    # end

    @comments = @project.comments.includes(:parent, user: :avatar)
    if is_whitelabel?
      @comments = @comments.joins(:user).where(users: { enable_sharing: true })
    end
  end

  def edit
    @project = Protip.find params[:id]
    authorize! :edit, @project
    title 'Edit protip'
    initialize_project
    @project = @project.decorate
    @show_admin_bar = true if params[:show_admin_bar] and current_user.is? :admin, :moderator
  end

  def update
    authorize! :update, @project
    private_was = @project.private

    if @project.update_attributes(params[:project])
      notice = "#{@project.name} was successfully updated."
      if private_was != @project.private
        if @project.private == false
          notice = nil# "#{@project.name} is now published. Somebody from the Hackster team still needs to approve it before it shows on the site. Sit tight!"
          session[:share_modal] = 'published_share_prompt'
          session[:share_modal_model] = 'protip'
          session[:share_modal_model_id] = @project.id
          session[:share_modal_time] = 'after_redirect'

          track_event 'Made project public', @project.to_tracker
        elsif @project.private == false
          notice = "#{@project.name} is now private again."
        end
      end
      @project = @project.decorate
      respond_with @project do |format|
        format.html do
          flash[:notice] = notice
          redirect_to @project
        end
      end

      track_event 'Updated project', @project.to_tracker.merge({ type: 'project update'})
    else
      if params[:project].try(:[], 'private') == '0'
        flash[:alert] = "Couldn't publish the protip, please email us at hi@hackster.io to get help."
      end
      redirect_to @project
    end
  end

  private
    def ensure_belongs_to_platform
      if is_whitelabel?
        if !ProjectCollection.exists?(@project.id, 'Group', current_platform.id) or @project.users.reject{|u| u.enable_sharing }.any?
          raise ActiveRecord::RecordNotFound
        end
      end
    end

    def initialize_project
      @project.build_cover_image unless @project.cover_image
    end
end
