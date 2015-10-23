class ProjectsController < ApplicationController
  before_filter :load_project_with_hid, only: [:show, :embed, :print, :update, :destroy]
  before_filter :load_project, only: [:redirect_to_slug_route]
  before_filter :ensure_belongs_to_platform, only: [:show, :embed, :print, :update, :destroy, :redirect_to_slug_route]
  before_filter :load_and_authorize_resource, only: [:edit, :submit, :update_workflow]
  respond_to :html
  after_action :allow_iframe, only: :embed
  skip_before_filter :track_visitor, only: [:show, :embed, :next]
  skip_after_filter :track_landing_page, only: [:show, :embed, :next]

  def index
    title "Explore all projects - Page #{safe_page_params || 1}"

    params[:sort] = (params[:sort].in?(BaseArticle::SORTING.keys) ? params[:sort] : 'trending')
    @by = (params[:by].in?(BaseArticle::FILTERS.keys) ? params[:by] : 'all')

    @projects = BaseArticle.indexable.for_thumb_display
    if params[:sort]
      @projects = @projects.send(BaseArticle::SORTING[params[:sort]])
    end

    if @by and @by.in? BaseArticle::FILTERS.keys
      @projects = @projects.send(BaseArticle::FILTERS[@by])
    end

    if params[:difficulty].try(:to_sym).in? BaseArticle::DIFFICULTIES.values
      @projects = @projects.where(difficulty: params[:difficulty])
    end

    if params[:type].try(:to_sym).in? BaseArticle.content_types(%w(Project Article)).values
      @projects = @projects.with_type(params[:type])
    end

    @projects = @projects.paginate(page: safe_page_params)

    respond_to do |format|
      format.html
      format.atom { render layout: false }
      format.rss { redirect_to projects_path(params.merge(format: :atom)), status: :moved_permanently }
    end
  end

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

    @challenge_entries = @project.challenge_entries.where(workflow_state: ChallengeEntry::APPROVED_STATES).includes(:challenge).includes(:prizes)
    @communities = @project.groups.where.not(groups: { type: 'Event' }).includes(:avatar).order(full_name: :asc)

    @hardware_parts = @project.part_joins.hardware.includes(part: :image)
    @software_parts = @project.part_joins.software.includes(part: :image)
    @tool_parts = @project.part_joins.tool.includes(part: :image)

    title @project.name
    @project_meta_desc = "#{@project.one_liner.try(:gsub, /\.$/, '')}. Find this and other hardware projects on Hackster.io."
    meta_desc @project_meta_desc
    @project = @project.decorate

    @other_projects = SimilarProjectsFinder.new(@project).results.for_thumb_display
    @other_projects = @other_projects.with_group current_platform if is_whitelabel?

    @team_members = @project.team_members.includes(:user).includes(user: :avatar)

    if @project.public?
      @respecting_users = @project.respecting_users.includes(:avatar).where.not(users: { full_name: nil }).limit(8)
      @replicating_users = @project.replicated_users.includes(:avatar).where.not(users: { full_name: nil }).limit(8)
      if is_whitelabel?
        @respecting_users = @respecting_users.where(users: { enable_sharing: true })
        @replicating_users = @replicating_users.where(users: { enable_sharing: true })
      end
    end

    @comments = @project.comments.includes(:parent, user: :avatar)
    if is_whitelabel?
      @comments = @comments.joins(:user).where(users: { enable_sharing: true })
    end

    if @project.has_assignment?
      @issue = Feedback.where(threadable_type: 'BaseArticle', threadable_id: @project.id).first
      @issue_comments = @issue.comments.includes(:user).includes(:parent) if @issue #.includes(user: :avatar)
    end

    # track_event 'Viewed project', @project.to_tracker.merge({ own: !!current_user.try(:is_team_member?, @project) })
  end

  def print
    authorize! :read, @project unless params[:auth_token] and params[:auth_token] == @project.security_token
    @project = @project.decorate
    render layout: 'print'
  end

  def claim
    @project = BaseArticle.find_by_id!(params[:id]).decorate
    authorize! :claim, @project

    @project.build_team unless @project.team
    if @project.external
      @project.team.members.new(user_id: current_user.id)
    else
      m = @project.team.members.new(user_id: current_user.id)
      m.permission_action = 'read'
      m.save
    end
    # @project.guest_name = nil
    @project.mark_needs_review! if @project.can_mark_needs_review?
    # @project.save

    redirect_to project_path(@project), notice: "You just claimed #{@project.name}. We'll let you know when it's approved!"
  end

  def embed
    surrogate_keys = [@project.record_key, "projects/#{@project.id}/embed"]
    surrogate_keys << current_platform.user_name if is_whitelabel?
    set_surrogate_key_header *surrogate_keys
    set_cache_control_headers

    title @project.name
    meta_desc "#{@project.one_liner.try(:gsub, /\.$/, '')}. Find this and other hardware projects on #{site_name}."
    @project = @project.decorate
    render layout: 'embed'

    # track_event 'Rendered embed thumbnail', @project.to_tracker.merge({ referrer: request.referrer })
  end

  def new
    model_class = if params[:type] and params[:type].in? BaseArticle::MACHINE_TYPES.keys
      BaseArticle::MACHINE_TYPES[params[:type]].constantize
    else
      Project
    end
    @project = model_class.new params[:base_article]
    authorize! :create, @project

    initialize_project
    event = if @project.external?
      'Attempted to submit a link'
    else
      'Attempted to create a project'
    end

    track_event event
  end

  def create
    model_class = if params[:base_article] and params[:base_article][:type] and params[:base_article][:type].in? BaseArticle::MACHINE_TYPES.values
      params[:base_article][:type].constantize
    else
      Project
    end
    @project = model_class.new params[:base_article]
    authorize! :create, @project

    if @project.external? or @project.product?
      event = 'Submitted link'
    else
      # @project.approve!
      @project.private = true
      event = 'Created project'
    end

    if @project.external?
      @project.content_type = :external
    end

    if current_platform
      @project.platform_tags_string = current_platform.name
    end

    if current_user
      @project.build_team
      @project.team.members.new(user_id: current_user.id)
    end

    if @project.save
      flash[:notice] = "#{@project.name} was successfully created."
      if @project.external? or @project.product?
        redirect_to user_return_to, notice: "Thanks for your submission!"
      else
        respond_with @project, location: edit_project_path(@project)
      end

      track_event event, @project.to_tracker
    else
      initialize_project
      render action: "new"
    end
  end

  def edit
    redirect_to @project, alert: "Your project is locked and cannot be edited at this time." if @project.locked? and !current_user.try(:is?, :admin)

    title 'Edit project'
    initialize_project
    @team = @project.team
    @show_admin_bar = true if params[:show_admin_bar] and current_user.is? :admin, :moderator
  end

  def update
    authorize! :update, @project

    respond_with @project do |format|
      format.html do
        private_was = @project.private
        if @project.update_attributes(params[:base_article])
          notice = "#{@project.name} was successfully updated."
          if private_was != @project.private
            if @project.private == false
              notice = nil# "#{@project.name} is now published. Somebody from the Hackster team still needs to approve it before it shows on the site. Sit tight!"
              session[:share_modal] = 'published_share_prompt'
              session[:share_modal_model] = 'project'
              session[:share_modal_model_id] = @project.id
              session[:share_modal_time] = 'after_redirect'

              track_event 'Made project public', @project.to_tracker
            elsif @project.private == false
              notice = "#{@project.name} is now private again."
            end
          end
          flash[:notice] = notice
        else
          if params[:base_article].try(:[], 'private') == '0'
            flash[:alert] = "Couldn't publish the project, please email us at hi@hackster.io to get help."
          end
        end
        redirect_to @project
      end

      format.js do
        @panel = params[:panel]

        # hack to clear up widgets that have somehow been deleted and that prevent all thing from being saved
        if params[:base_article].try(:[], :widgets_attributes)
          widgets = {}
          params[:base_article][:widgets_attributes].each do |i, widget|
            widgets[i] = widget if widget['id'].present?
          end
          all = Widget.where(id: widgets.values.map{|v| v['id'] }).pluck(:id).map{|i| i.to_s }
          widgets.each do |i, widget|
            unless all.include? widget['id']
              params[:base_article][:widgets_attributes].delete(i)
            end
          end
        end

        begin
          if (params[:save].present? and params[:save] == '0') or @project.update_attributes params[:base_article]
            if @panel.in? %w(hardware publish team software protip_attachments protip_parts)
              render 'projects/forms/update'
            else
              render 'projects/forms/checklist', status: :ok
            end
          else
            message = "Couldn't save project: #{@project.inspect} // user: #{current_user.user_name} // params: #{params.inspect} // errors: #{@project.errors.inspect}"
            log_line = LogLine.create(message: message, log_type: '422', source: 'api/projects')
            # NotificationCenter.notify_via_email nil, :log_line, log_line.id, 'error_notification' if ENV['ENABLE_ERROR_NOTIF']
            render json: { base_article: @project.errors }, status: :unprocessable_entity
          end
        rescue => e
          message = "Couldn't save project: #{@project.inspect} // user: #{current_user.try(:user_name)} // params: #{params.inspect} // exception: #{e.inspect}"
          log_line = LogLine.create(message: message, log_type: '5xx', source: 'api/projects')
          NotificationCenter.notify_via_email nil, :log_line, log_line.id, 'error_notification' if ENV['ENABLE_ERROR_NOTIF']
          render status: :internal_server_error, nothing: true
          raise e if Rails.env.development?
        end
      end
    end

    # track_event 'Updated project', @project.to_tracker.merge({ type: 'project update'})
  end

  def update_workflow
    if @project.send "#{params[:event]}!", reviewer_id: current_user.id, review_comment: params[:comment]
      flash[:notice] = "Article state changed to: #{params[:event]}."
      redirect_to admin_projects_path(workflow_state: 'pending_review')
    else
      # flash[:error] = "Couldn't #{params[:event].gsub(/_/, ' ')} challenge, please try again or contact an admin."
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @project

    @project.destroy

    flash[:notice] = "Farewell #{@project.name}, we loved you."

    respond_with current_user
  end

  def redirect_to_slug_route
    if @project.public?
      redirect_to url_for(@project), status: 301
    else
      redirect_to polymorphic_path(@project, auth_token: params[:auth_token])
    end
  end

  def redirect_to_last
    project = BaseArticle.last
    url = case project
    when Product
      product_path(project)
    when ExternalProject
      project_path(project)
    else
      url_for(project)
    end
    redirect_to url, status: 302
  end

  def submit
    authorize! :edit, @project
    msg = 'Your assignment has been submitted. '
    @project.assignment_submitted_at = Time.now
    if @project.assignment.past_due? or !(deadline = @project.assignment.submit_by_date)
      @project.locked = true
      msg += 'The project will be locked for modifications until grades are sent out.'
    else
      msg += "You can still make modifications to the project until the submission deadline on #{l deadline.in_time_zone(PDT_TIME_ZONE)} PT."
    end
    @project.save
    redirect_to @project, notice: msg
  end

  # next/previous project in search
  def next
    cache_key = [params[:ref], params[:ref_id], params[:dir], params[:offset]]

    if params[:ref] == 'custom'
      if user_signed_in?
        cache_key << current_user.id
      else
        params[:ref] = 'similar'
        params[:ref_id] = params[:id]
        params[:offset] = nil
      end
    else
      surrogate_keys = ["projects/#{params[:id]}", 'projects/next']
      surrogate_keys << current_platform.user_name if is_whitelabel?
      set_surrogate_key_header *surrogate_keys
      set_cache_control_headers
    end

    if params[:ref_id].nil? or params[:ref].nil?
      params[:ref_id] = params[:id] || Project.indexable.last.id
      params[:ref] = 'similar'
    end

    next_url = Rails.cache.fetch(cache_key.join('/'), expires_in: 3.hours) do
      case params[:ref]
      when 'assignment', 'explore', 'event', 'user', 'platform', 'part', 'tag', 'userrespected', 'custom'
        offset = params[:offset].to_i
        offset += params[:dir] == 'prev' ? -1 : 1

        @results = case params[:ref]
        when 'assignment'
          if assignment = Assignment.find_by_id(params[:ref_id])
            assignment.projects.public.order(:created_at)
          end

        when 'custom'
          if current_user.id.to_s != params[:ref_id]
            offset = 0
            params[:ref_id] = current_user.id
          end
          BaseArticle.custom_for(current_user)

        when 'explore'
          sort, by, difficulty, type = params[:ref_id].split(/_/)

          projects = BaseArticle
          if sort.in? BaseArticle::SORTING.keys
            projects = projects.send(BaseArticle::SORTING[sort])
          end

          if by.in? BaseArticle::FILTERS.keys
            projects = projects.send(BaseArticle::FILTERS[by])
          end

          if difficulty and difficulty.to_sym.in? BaseArticle::DIFFICULTIES.values
            projects = projects.where(difficulty: difficulty)
          end

          if type and type.to_sym.in? BaseArticle.content_types(%w(Project Article)).values
            projects = projects.with_type(type)
          end

          projects = projects.with_group(current_platform) if is_whitelabel?
          projects.indexable

        when 'event'
          if event = Event.find_by_id(params[:ref_id])
            event.projects.public.order('projects.respects_count DESC')
          end

        when 'platform'
          id, sort, by, difficulty, type = params[:ref_id].split(/_/)

          if platform = Platform.find_by_id(id)
            sort = if sort.in? BaseArticle::SORTING.keys
              sort
            else
              sort = platform.project_sorting.presence || 'trending'
            end
            by ||= 'all'

            projects = platform.project_collections.references(:project).includes(:project).visible.featured_order(I18n.short_locale).merge(BaseArticle.for_thumb_display_in_collection)
            projects = if sort == 'recent'
              projects.most_recent
            else
              projects.merge(BaseArticle.send(BaseArticle::SORTING[sort]))
            end

            if difficulty.try(:to_sym).in? BaseArticle::DIFFICULTIES.values
              projects = projects.joins(:project).merge(BaseArticle.where(difficulty: difficulty))
            end

            if type.try(:to_sym).in? BaseArticle.content_types(%w(Project Article)).values
              projects = projects.joins(:project).merge(BaseArticle.with_type(type))
            end

            # if params[:tag]
            #   @projects = @projects.joins(:project).joins(project: :product_tags).where("LOWER(tags.name) = ?", CGI::unescape(params[:tag]))
            # end

            if by and by.in? BaseArticle::FILTERS.keys
              projects = if by == 'featured'
                projects.featured
              else
                projects.merge(BaseArticle.send(BaseArticle::FILTERS[by]))
              end
            end

            projects
          end

        when 'part'
          if part = Part.find_by_id(params[:ref_id])
            part.projects.public.magic_sort
          end

        when 'tag'
          tag = params[:ref_id]
          projects = BaseArticle.indexable.joins("INNER JOIN tags ON tags.taggable_id = projects.id AND tags.taggable_type = 'BaseArticle'").where(tags: { type: %w(ProductTag PlatformTag) }).where("LOWER(tags.name) = ?", tag.downcase).uniq
          projects = projects.joins(:project_collections).where(project_collections: { collectable_id: current_platform.id, collectable_type: 'Group' }) if is_whitelabel?
          projects.magic_sort

        when 'user'
          if user = User.find_by_id(params[:ref_id])
            projects = user.projects.public.own.order(start_date: :desc, created_at: :desc)
            projects = projects.with_group(current_platform) if is_whitelabel?
            projects
          end

        when 'userrespected'
          if user = User.find_by_id(params[:ref_id])
            projects = user.respected_projects.indexable_and_external.order('respects.created_at DESC')
            projects = projects.with_group(current_platform) if is_whitelabel?
            projects
          end
        end

        if @results.present?
          if offset < 0
            offset = [@results.offset(nil).limit(nil).size - 1, 0].max
          end

          while !(@next = @results.offset(offset).first)
            if offset != 0
              offset = 0
              flash[:notice] = "You've looped through all related projects. Starting from first result again."
            end
          end

          if @next.kind_of? ProjectCollection
            @next = @next.project
          end
        end

      when 'challenge'
        # Since we have two sets of data (winning_entries and other_projects), we
        # can't use pg's offset. sSo instead we put all the ids in an array and
        # use the current project's index to find the next/prev project. Since
        # challenges have usually few (<1000) projects, this shouldn't be an issue.
        if challenge = Challenge.find_by_id(params[:ref_id])
          if challenge.judged?
            winning_entries = challenge.entries.winning.includes(:project).inject([]){|mem, e| mem << e unless mem.select{|m| m.project_id == e.project_id }.any?; mem }.map{|e| e.project_id }
            other_projects = challenge.projects.reorder("(CASE WHEN projects.workflow_state = 'approved' THEN 1 ELSE 2 END) ASC").most_respected.where.not(challenge_projects: { id: winning_entries }).pluck(:id)
            projects = winning_entries + other_projects
          else
            projects = challenge.projects.valid.reorder("(CASE WHEN projects.workflow_state = 'approved' THEN 1 ELSE 2 END) ASC, challenge_projects.created_at DESC").pluck(:id)
          end

          offset = params[:offset].to_i
          offset += params[:dir] == 'prev' ? -1 : 1
          if offset < 0
            offset = [projects.size - 1, 0].max
          elsif offset >= projects.size
            offset = 0
            flash[:notice] = "You've looped through all related projects. Starting from first result again."
          end

          id = projects[offset]
          @next = BaseArticle.find(id)
        end

      when 'search'
        params[:q] = params[:ref_id]
        params[:type] = 'base_article'
        params[:per_page] = 1
        params[:include_external] = false
        params[:platform_id] = current_platform.id if is_whitelabel?

        # - first result (offset 0)
        #   - prev => go to last result
        # - last result (offset n)
        #   - next => go to first result
        # - else => go to +/- 1

        offset = params[:offset].to_i
        if offset == 0 and params[:dir] == 'prev'
          offset = SearchRepository.new(params).search.results.total_count - 1
        else
          offset += (params[:dir] == 'prev' ? -1 : 1)
        end

        @results = SearchRepository.new(params.merge(offset: offset)).search.results

        # handle next for last result
        if !(@next = @results.first) and offset > 0
          offset = 0
          @results = SearchRepository.new(params.merge(offset: 0)).search.results
          @next = @results.first
        end

      when 'similar'
        project = BaseArticle.find params[:ref_id]
        @results = SimilarProjectsFinder.new(project, limit: 1).results
        @results = @results.with_group(current_platform) if is_whitelabel?

        # - current project (offset is nil):
        #   - prev => go to last similar project
        #   - next => go to first similar project
        # - project right after (offset 0):
        #   - prev => go back to main project
        # - project right before (offset n):
        #   - next => go back to main project
        # - else => go to +/- 1

        offset = if params[:offset]
          if params[:offset].to_i.zero? and params[:dir] == 'prev'
            @next = project
            offset = nil
          else
            params[:offset].to_i + (params[:dir] == 'prev' ? -1 : 1)
          end
        elsif params[:dir] == 'prev'
          [@results.offset(nil).limit(nil).size - 1, 0].max
        else
          0
        end

        # handle next for last result
        if @next.nil? and !(@next = @results.offset(offset).first)
          @next = project
          offset = nil
        end
      end

      if @next
        project_path(@next, ref: params[:ref], ref_id: params[:ref_id], offset: offset)
      else
        project_path(BaseArticle.magic_sort.first, ref: params[:ref], ref_id: params[:ref_id], offset: params[:offset])
      end
    end

    redirect_to next_url
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

    def load_and_authorize_resource
      @project = BaseArticle.find params[:id]
      authorize! self.action_name, @project
    end
end