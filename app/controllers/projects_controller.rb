class ProjectsController < ApplicationController
  before_filter :load_project_with_hid, only: [:show, :embed, :print, :update, :destroy]
  before_filter :load_project, only: [:redirect_to_slug_route]
  before_filter :ensure_project_belongs_to_platform, only: [:show, :embed, :print, :redirect_to_slug_route]
  before_filter :load_and_authorize_resource, only: [:edit, :submit, :update_workflow]
  respond_to :html
  after_action :allow_iframe, only: [:embed, :embed_collection]
  skip_before_filter :track_visitor, only: [:show, :embed, :embed_collection, :next]
  skip_after_filter :track_landing_page, only: [:show, :embed, :embed_collection, :next]

  def index
    title "Explore all projects - Page #{safe_page_params || 1}"

    params[:sort] = (params[:sort].in?(Project::SORTING.keys) ? params[:sort] : 'trending')
    @by = (params[:by].in?(Project::FILTERS.keys) ? params[:by] : 'all')

    @projects = Project.for_thumb_display

    @projects = params[:show_all] ? @projects.published : @projects.indexable

    if @by and @by.in? Project::FILTERS.keys
      @projects = @projects.send(Project::FILTERS[@by], user: current_user)
      if @by == 'toolbox'
        @projects = @projects.distinct('projects.id')  # see if this can be moved out
      end
      @by = case @by
      when '7days'
        '7 days of'
      when '30days'
        '30 days of'
      when '1year'
        '12 months of'
      else
        @by
      end
    end

    if params[:sort]
      @projects = @projects.send(Project::SORTING[params[:sort]])
    end

    if params[:difficulty].try(:to_sym).in? Project::DIFFICULTIES.values
      @projects = @projects.where(difficulty: params[:difficulty])
    end

    if params[:type].try(:to_sym).in? Project.content_types(%w(Project Article)).values
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
    elsif @project.publyc?  # don't cache if project is private
      surrogate_keys = [@project.record_key, 'project']
      surrogate_keys << current_platform.user_name if is_whitelabel?
      set_surrogate_key_header *surrogate_keys
      set_cache_control_headers
    end

    @can_edit = (user_signed_in? and current_user.can? :edit, @project)

    # we have to support two different templates
    if current_platform.try(:user_name) == 'arduino'
      # we load parts and widgets all at once and then split them into their own
      # categories. That way we limit the number of db queries
      @parts = @project.part_joins.includes(part: [:image, :platform])

      @hardware_parts = @parts.select{|p| p.part.type == 'HardwarePart' } unless Rails.cache.exist?(['views', I18n.locale, "project-#{@project.id}-hardware-parts", site_user_name]) and Rails.cache.exist?(['views', "project-#{@project.id}-contents-hardware-parts"])
      @tool_parts = @parts.select{|p| p.part.type == 'ToolPart' } unless Rails.cache.exist?(['views', I18n.locale, "project-#{@project.id}-tool-parts", site_user_name]) and Rails.cache.exist?(['views', "project-#{@project.id}-contents-tool-parts"])
      @software_parts = @parts.select{|p| p.part.type == 'SoftwarePart' } unless Rails.cache.exist?(['views', I18n.locale, "project-#{@project.id}-software-parts", site_user_name]) and Rails.cache.exist?(['views', "project-#{@project.id}-contents-software-parts"])

      @widgets = @project.widgets.order(:position, :id)
      unless Rails.cache.exist?(['views', I18n.locale, "project-#{@project.id}-credits"])
        @credits_widget = @widgets.select{|w| w.type == 'CreditsWidget' }.first
        @credit_lines = @credits_widget ? @credits_widget.credit_lines : []
      end
    else
      @winning_entry = @project.challenge_entries.where(workflow_state: :awarded).includes(:challenge).includes(:prizes).first
      @communities = @project.groups.where.not(groups: { type: 'Event' }).includes(:avatar).order(full_name: :asc)

      unless Rails.cache.exist?(['views', I18n.locale, "project-#{@project.id}-teaser", site_user_name, user_signed_in?])
        @tags = if @project.product_tags_cached.any? or @project.platform_tags_cached.any?
          unknown_platforms = @project.platform_tags_cached.select do |tag|
            Platform.includes(:platform_tags).references(:tags).where("LOWER(tags.name) = ?", tag.downcase).first.nil?
          end
          tags = (@project.product_tags_cached  + unknown_platforms).map{|t| t.downcase }.uniq
        else
          []
        end
      end

      unless Rails.cache.exist?(['views', I18n.locale, "project-#{@project.id}-parts", site_user_name]) and Rails.cache.exist?(['views', "project-#{@project.id}-contents-parts"])
        # we load parts and widgets all at once and then split them into their own
        # categories. That way we limit the number of db queries
        @parts = @project.part_joins.includes(part: [:image, :platform])
        @hardware_parts = @parts.select{|p| p.part.type == 'HardwarePart' }
        @tool_parts = @parts.select{|p| p.part.type == 'ToolPart' }
        @software_parts = @parts.select{|p| p.part.type == 'SoftwarePart' }
      end

      @widgets = @project.widgets.order(:position, :id)
      unless Rails.cache.exist?(['views', I18n.locale, "project-#{@project.id}-team"])
        @credits_widget = @widgets.select{|w| w.type == 'CreditsWidget' }.first
        @credit_lines = @credits_widget ? @credits_widget.credit_lines : []
      end
    end

    @cad_widgets = @widgets.select{|w| w.type.in? %w(CadRepoWidget CadFileWidget) } unless Rails.cache.exist?(['views', I18n.locale, "project-#{@project.id}-cad"]) and Rails.cache.exist?(['views', "project-#{@project.id}-contents-cad"])
    @schematic_widgets = @widgets.select{|w| w.type.in? %w(SchematicWidget SchematicFileWidget) } unless Rails.cache.exist?(['views', I18n.locale, "project-#{@project.id}-schematics"]) and Rails.cache.exist?(['views', "project-#{@project.id}-contents-schematics"])
    unless Rails.cache.exist?(['views', I18n.locale, "project-#{@project.id}-code"]) and Rails.cache.exist?(['views', "project-#{@project.id}-contents-code"])
      @code_widgets = @widgets.select{|w| w.type.in? %w(CodeWidget CodeRepoWidget) }
      @code_file_widgets = @code_widgets.select{|w| w.type.in? %w(CodeWidget) }
      @code_repo_widgets = @code_widgets.select{|w| w.type.in? %w(CodeRepoWidget) }
    end

    title @project.name
    @project_meta_desc = "#{@project.one_liner.try(:gsub, /\.$/, '')}. Find this and other hardware projects on Hackster.io."
    meta_desc @project_meta_desc

    @other_projects = SimilarProjectsFinder.new(@project).results.for_thumb_display
    @other_projects = @other_projects.with_group current_platform if is_whitelabel?

    @team_members = @project.team_members.includes(:user).includes(user: :avatar)

    if @project.publyc?
      @respecting_users = @project.respecting_users.publyc.includes(:avatar).where.not(users: { full_name: nil }).limit(current_platform.try(:user_name) == 'arduino' ? 8 : 9)
      @replicating_users = @project.replicated_users.publyc.includes(:avatar).where.not(users: { full_name: nil }).limit(8)
      if is_whitelabel?
        @respecting_users = @respecting_users.where(users: { enable_sharing: true })
        @replicating_users = @replicating_users.where(users: { enable_sharing: true })
      end
    end

    @comments = @project.comments.includes(:parent, user: :avatar)
    if is_whitelabel?
      @comments = @comments.joins(:user).where(users: { enable_sharing: true })
    end

    @project = ProjectDecorator.decorate(@project)
    # preload widgets and images
    unless (current_platform.try(:user_name) == 'arduino' ? Rails.cache.exist?(['views', I18n.locale, "project-#{@project.id}-widgets"]) : Rails.cache.exist?(['views', I18n.locale, "project-#{@project.id}-story"]) and Rails.cache.exist?(['views', I18n.locale, "project-#{@project.id}-contents-story"]))
      @description = if @project.story_json.empty?
        @image_widgets = @widgets.select{|w| w.type == 'ImageWidget' }
        @images = Image.where(attachable_type: 'Widget', attachable_id: @image_widgets.map(&:id))
        @project.description(nil, widgets: @widgets, images: @images)
      else
        @project.story_json.html_safe
      end
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

  def embed_collection
    not_found and return unless params[:hids].present?

    hids = params[:hids].split(/,/)
    @projects = BaseArticle.where(hid: hids).paginate(page: safe_page_params)
    surrogate_keys = ["projects/embed_collection"]
    surrogate_keys << current_platform.user_name if is_whitelabel?
    set_surrogate_key_header *surrogate_keys
    set_cache_control_headers

    params[:sort] = (params[:sort].in?(BaseArticle::SORTING.keys) ? params[:sort] : 'trending')
    if params[:sort]
      @projects = @projects.send(BaseArticle::SORTING[params[:sort]])
    end

    @column_width = params[:col_width]
    @column_class = @column_width ? 'no-col' : (params[:col_class] ? CGI.unescape(params[:col_class]) : nil)

    title 'Hardware projects on Hackster.io'
    render layout: 'embed'
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
      @project.pryvate = true
      event = 'Created project'
    end

    if @project.external?
      @project.content_type = :external
    end

    if current_platform
      @project.origin_platform_id = current_platform.id
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
    redirect_to @project, alert: "Your project is locked and cannot be edited at this time." if @project.locked? and !current_user.try(:is?, :admin, :hackster_moderator)

    title 'Edit project'
    initialize_project
    @team = @project.team
  end

  def update
    authorize! :update, @project

    respond_with @project do |format|
      format.html do
        private_was = @project.pryvate
        type_was = @project.type
        if @project.update_attributes(params[:base_article])
          notice = "#{@project.name} was successfully updated."
          if private_was != @project.pryvate
            ProjectWorker.perform_async 'create_review_event', @project.id, current_user.id, :project_privacy_update, privacy: @project.pryvate
            if @project.pryvate == false
              notice = "Your project is now public!"
              notice << " Is it complete and ready for prime time? Publish it." if @project.unpublished?

              track_event 'Made project public', @project.to_tracker
            elsif @project.pryvate == false
              notice = "#{@project.name} is now private again."
            end
          elsif type_was != @project.type
            notice = "The project template was updated."
          end
          redirect_to @project, notice: notice
        else
          if params[:base_article].try(:[], 'private') == '0'
            flash[:alert] = "Couldn't make the project public, please email us at help@hackster.io to get help."
          end
          if params[:view].present?
            render params[:view]
          else
            redirect_to @project
          end
        end
      end

      format.js do
        @panel = params[:panel]

        begin
          # @project.assign_attributes params[:base_article]
          # did_change = @project.changed?
          # changed = @project.changed

          @project.updater_id = current_user.id
          if (params[:save].present? and params[:save] == '0') or @project.update_attributes params[:base_article]
            # ProjectWorker.perform_async 'create_review_event', @project.id, current_user.id, :project_update, changed: changed if did_change
            if @panel.in? %w(hardware things publish team software protip_parts_and_attachments attachments)
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
    not_found and return unless params[:event]

    @project = BaseArticle.find params[:id]
    authorize! params[:event], @project

    if current_user.is? :admin, :hackster_moderator
      if @project.send "#{params[:event]}!", reviewer_id: current_user.id, review_comment: params[:comment]
        @ok = true
        next_url = if params[:event] == 'publish' or params[:event] == 'unpublish'
          @project
        else
          admin_projects_path(workflow_state: 'pending_review')
        end
        redirect_to next_url
      else
        render :edit
      end
    else
      if @project.send "#{params[:event]}!"
        @ok = true
      else
        flash[:alert] = "Couldn't #{params[:event]} this write-up."
      end
      redirect_to @project
    end

    if @ok
      if params[:event] == 'publish'
        ProjectWorker.perform_async 'create_review_event', @project.id, current_user.id, :project_status_update, workflow_state: @project.workflow_state
        session[:share_modal] = 'published_share_prompt'
        session[:share_modal_model] = 'project'
        session[:share_modal_model_id] = @project.id
        session[:share_modal_time] = 'after_redirect'
      elsif params[:event] == 'unpublish'
        flash[:notice] = "Write-up unpublished."
      else
        flash[:notice] = "Write-up #{params[:event]}'ed."
      end
    end
  end

  def publish
    @project = BaseArticle.find params[:id]
    authorize! :manage, @project

    title "Publication settings - #{@project.name}"
  end

  def destroy
    authorize! :destroy, @project

    @project.destroy

    flash[:notice] = "Farewell #{@project.name}, we loved you."

    respond_with current_user
  end

  def redirect_to_slug_route
    if @project.publyc?
      redirect_to url_for(@project), status: 301
    else
      redirect_to polymorphic_path(@project, auth_token: params[:auth_token])
    end
  end

  def redirect_to_last
    project = is_whitelabel? ? current_platform.projects.last : BaseArticle.last
    redirect_to url_for(project), status: 302
  end

  def submit
    authorize! :edit, @project
    msg = 'Your assignment has been submitted. '
    @project.assignment_submitted_at = Time.now
    if @project.assignment.past_due?
      if @project.assignment.should_lock?
        @project.locked = true
        msg += 'The project will be locked for modifications until grades are sent out.'
      end
    elsif @project.assignment.submit_by_date.present?
      msg += "You can still make modifications to the project until the submission deadline on #{l @project.assignment.submit_by_date.in_time_zone(PDT_TIME_ZONE)} PT."
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
      when 'assignment', 'explore', 'event', 'user', 'platform', 'part', 'tag', 'userrespected', 'custom', 'list'
        offset = params[:offset].to_i
        offset += params[:dir] == 'prev' ? -1 : 1

        @results = case params[:ref]
        when 'assignment'
          if assignment = Assignment.find_by_id(params[:ref_id])
            assignment.projects.publyc.order(:created_at)
          end

        when 'custom'
          if current_user.id.to_s != params[:ref_id]
            offset = 0
            params[:ref_id] = current_user.id
          end
          BaseArticle.indexable.custom_for(current_user).last_featured

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
            event.projects.publyc.order('projects.respects_count DESC')
          end

        when 'list'
          if list = List.find_by_id(params[:ref_id])
            list.projects.visible.order('project_collections.workflow_state DESC').magic_sort
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
            part.projects.publyc.magic_sort
          end

        when 'tag'
          tag = params[:ref_id]
          projects = BaseArticle.indexable.joins("INNER JOIN tags ON tags.taggable_id = projects.id AND tags.taggable_type = 'BaseArticle'").where(tags: { type: %w(ProductTag PlatformTag) }).where("LOWER(tags.name) = ?", tag.downcase).uniq
          projects = projects.joins(:project_collections).where(project_collections: { collectable_id: current_platform.id, collectable_type: 'Group' }) if is_whitelabel?
          projects.magic_sort

        when 'user'
          if user = User.find_by_id(params[:ref_id])
            projects = user.projects.publyc.own.order(created_at: :desc)
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
        params[:model_classes] = %w(BaseArticle)
        params[:per_page] = 1
        params[:platform_id] = current_platform.id if is_whitelabel?

        # - first result (offset 0)
        #   - prev => go to last result
        # - last result (offset n)
        #   - next => go to first result
        # - else => go to +/- 1

        offset = params[:offset].to_i
        if offset == 0 and params[:dir] == 'prev'
          offset = Search.new(params).hits['base_article'][:total_size] - 1
        else
          offset += (params[:dir] == 'prev' ? -1 : 1)
        end

        @results = Search.new(params.merge(page: offset + 1)).hits['base_article'][:models]

        # handle next for last result
        if !(@next = @results.first) and offset > 0
          offset = 0
          @results = Search.new(params.merge(page: 1)).hits['base_article'][:models]
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
    def initialize_project
      @project.build_cover_image unless @project.cover_image
    end

    def load_and_authorize_resource
      @project = BaseArticle.find params[:id]
      authorize! self.action_name, @project
    end
end