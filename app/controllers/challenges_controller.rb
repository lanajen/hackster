class ChallengesController < MainBaseController
  before_filter :authenticate_user!, only: [:edit, :update, :update_workflow, :dashboard]
  before_filter :load_challenge, only: [:show, :brief, :projects, :participants, :ideas, :idea, :idea_winners, :faq, :update]
  before_filter :authorize_and_set_cache, only: [:show, :brief, :projects, :ideas, :idea_winners, :faq]
  before_filter :load_side_models, only: [:show, :brief, :projects, :participants, :ideas, :idea, :idea_winners, :faq]
  before_filter :load_and_authorize_challenge, only: [:enter, :update_workflow]
  before_filter :set_challenge_entrant, only: [:show, :brief, :projects, :participants, :ideas, :idea, :idea_winners, :faq]
  before_filter :load_user_projects, only: [:show, :brief, :projects, :participants, :ideas, :idea, :idea_winners, :faq]
  before_filter :set_hello_world, only: [:show, :brief, :projects, :participants, :ideas, :idea, :idea_winners, :faq]
  load_and_authorize_resource only: [:edit, :update]
  layout :set_layout
  skip_before_filter :track_visitor, only: [:show, :brief, :projects, :ideas, :idea_winners]
  skip_after_filter :track_landing_page, only: [:show, :brief, :projects, :ideas, :idea_winners]

  def index
    title 'Hardware contests'
    meta_desc "Build the best hardware projects and win awesome prizes!"

    @active_challenges = Challenge.visible.active.ends_last.includes(:alternate_cover_image, :cover_image, sponsors: :avatar)
    @coming_challenges = Challenge.visible.coming.starts_first.includes(sponsors: :avatar)
    @past_challenges = Challenge.visible.past.ends_last.includes(sponsors: :avatar)

    respond_to do |format|
      format.html
      format.atom { render layout: false }
      format.rss { redirect_to challenges_path(params.merge(format: :atom).reject{|k, v| k.to_s.in? %w(action controller)}), status: :moved_permanently }
    end
  end

  def show
    title @challenge.name

    if @challenge.judged? and !@challenge.disable_projects_phase?
      load_projects
      render 'challenges/projects'
    else
      render 'challenges/brief'
    end
  end

  def brief
    title "#{@challenge.name} brief"
  end

  def projects
    not_found and return if @challenge.disable_projects_tab? and !@challenge.judged?

    title "#{@challenge.name} projects"
    load_projects
  end

  def participants
    not_found and return if @challenge.disable_participants_tab?

    title "#{@challenge.name} participants"
    respond_to do |format|
      format.html do
        @participants = @challenge.registrants.includes(:avatar).reorder("challenge_registrations.created_at DESC").paginate(page: safe_page_params, per_page: 60)
      end
    end
  end

  def ideas
    not_found and return if @challenge.disable_ideas_tab?

    title "#{@challenge.name} ideas"
    @ideas = @challenge.ideas
    @ideas = @ideas.old_approved unless @challenge.activate_free_hardware?
    @ideas = @ideas.order(created_at: :desc).includes(user: :avatar).paginate(per_page: 12, page: safe_page_params)
  end

  def idea
    @idea = @challenge.ideas.find params[:id]
  end

  def idea_winners
    redirect_to @challenge and return unless @challenge.pre_contest_awarded?

    @ideas = @challenge.ideas.won.joins(:user).includes(:image, user: :avatar).order('users.full_name, users.user_name')
  end

  def faq
    title "#{@challenge.name} FAQ"
    @faq_entries = @challenge.faq_entries.publyc.order("LOWER(threads.title) ASC")
    @default_faqs = @challenge.default_faq_entries.publyc.order("LOWER(threads.title) ASC")
    @cache_keys = Rails.cache.fetch("challenge-#{@challenge.id}-faq-cache-tags") do
      @faq_entries.map{|f| f.token_tags.try(:values) || [] }.flatten.uniq.map{|v| "challenge-#{@challenge.id}-#{v}"}
    end
  end

  def dashboard
    @challenge = Challenge.find params[:challenge_id]
    authorize! :admin, @challenge

    if @challenge.activate_pre_contest? or @challenge.activate_free_hardware?
      @ideas = @challenge.ideas.joins(:user).order(:created_at)
      @approved_ideas_count = @ideas.where(workflow_state: ChallengeIdea::OLD_APPROVED_STATES).count
      @rejected_ideas_count = @ideas.where(workflow_state: 'rejected').count
      @new_ideas_count = @ideas.where(workflow_state: 'new').count
    end

    @entries = @challenge.entries.joins(:project, :user).includes(:prizes, user: :avatar, project: :team).order(:created_at)
    @new_entries_count = @entries.where(workflow_state: 'new').count
    @submitted_entries_count = @entries.where(workflow_state: 'submitted').count
    @approved_entries_count = @entries.where(workflow_state: ChallengeEntry::APPROVED_STATES).count
    @rejected_entries_count = @entries.where(workflow_state: 'unqualified').count

    # determines how many of each prizes were awarded and how many are left
    if @challenge.judging?
      assigned_prizes = {}
      @entries.joins(:prizes).pluck('prizes.id').each do |id|
        assigned_prizes[id] = 0 unless id.in? assigned_prizes
        assigned_prizes[id] += 1
      end
      @prizes = {}
      @challenge.prizes.each do |prize|
        quantity = prize.quantity - assigned_prizes[prize.id].to_i
        @prizes[prize] = quantity unless quantity.zero?
      end
    end
    @challenge = @challenge.decorate
  end

  def update
    authorize! :update, @challenge
    @challenge.assign_attributes(params[:challenge])
    message = if @challenge.pre_contest_awarded_changed? and @challenge.pre_contest_awarded?
      'The announcement is being processed in the background. Results and emails will be visible momentarily.'
    else
      'Changes saved.'
    end
    if @challenge.save
      redirect_to @challenge, notice: message
    else
      render 'edit'
    end
  end

  def update_mailchimp
    @challenge = Challenge.find params[:id]
    authorize! :admin, @challenge
    MailchimpWorker.perform_async 'sync_challenge', @challenge.id
    redirect_to @challenge, notice: 'Your Mailchimp will be updated shortly.'
  end

  def update_workflow
    if @challenge.send "#{params[:event]}!"
      flash[:notice] = if params[:event] == 'mark_as_judged'
        "Marking as judged. Should take a few minutes. If the projects page isn't showing the winning entries in a few minutes, email us."
      else
        "Challenge #{event_to_human(params[:event])}."
      end
      redirect_to @challenge
    else
      # flash[:error] = "Couldn't #{params[:event].gsub(/_/, ' ')} challenge, please try again or contact an admin."
      render :edit
    end
  end

  def unlock
    @challenge = Challenge.find params[:id]
    redirect_to @challenge and return unless @challenge.password_protect?

    if key = @challenge.unlock(params[:password]).presence
      session[:challenge_keys] ||= {}
      session[:challenge_keys][@challenge.id] = key
    else
      flash[:alert] = 'The password you entered is incorrect.'
    end

    redirect_to @challenge
  end

  private
    def authorize_and_set_cache
      authorize! :read, @challenge

      if user_signed_in? or @challenge.password_protect?
        impressionist_async @challenge, '', unique: [:session_hash]
      else
        surrogate_keys = [@challenge.record_key, 'challenge']
        set_surrogate_key_header *surrogate_keys
        set_cache_control_headers
      end
    end

    def event_to_human event
      case event
      when 'mark_as_judged'
        'marked as judged'
      else
        "#{event}ed"
      end
    end

    def load_challenge
      @challenge = Challenge.where("LOWER(challenges.slug) = ?", params[:slug].downcase).first!
      if params[:slug] != @challenge.slug
        redirect_to request.fullpath.gsub(params[:slug], @challenge.slug) and return
      end
      @challenge = @challenge.decorate
    end

    def load_and_authorize_challenge
      @challenge = Challenge.find params[:id]
      authorize! self.action_name.to_sym, @challenge
    end

    def load_side_models
      @sponsors = GroupDecorator.decorate_collection(@challenge.sponsors.includes(:avatar))
      @prizes = @challenge.prizes.includes(:image)
    end

    def load_projects
      per_page = Challenge.per_page
      if @challenge.judged?
        if params[:category_id]
          @category = ChallengeCategory.where(id: params[:category_id], challenge_id: @challenge.id).first!
          @projects = @challenge.projects.reorder("(CASE WHEN projects.workflow_state = 'approved' THEN 1 ELSE 2 END) ASC").with_category(params[:category_id]).most_respected.for_thumb_display.paginate(page: safe_page_params, per_page: per_page)
        else
          @winning_entries = @challenge.entries.winning.includes(:project).inject([]){|mem, e| mem << e unless mem.select{|m| m.project_id == e.project_id }.any?; mem }
          @winning_entries_count = @winning_entries.count
          @other_projects = @challenge.projects.reorder("(CASE WHEN projects.workflow_state = 'approved' THEN 1 ELSE 2 END) ASC").most_respected.where.not(challenge_projects: { id: @winning_entries.map(&:id) }).for_thumb_display.paginate(page: safe_page_params, per_page: per_page)
        end
      else
        per_page = per_page - 1 if @challenge.open_for_submissions? and !@is_challenge_entrant
        @projects = @challenge.projects.valid.reorder("(CASE WHEN projects.workflow_state = 'approved' THEN 1 ELSE 2 END) ASC, challenge_projects.created_at DESC")

        if params[:category_id]
          @category = ChallengeCategory.where(id: params[:category_id], challenge_id: @challenge.id).first!
          @projects = @projects.with_category(params[:category_id])
        end

        @projects = @projects.for_thumb_display.paginate(page: safe_page_params, per_page: per_page)
      end
    end

    def load_user_projects
      if user_signed_in? and @challenge.open_for_submissions?
        @user_projects = current_user.projects.own.where("NOT projects.id IN (SELECT projects.id FROM projects INNER JOIN challenge_projects ON projects.id = challenge_projects.project_id WHERE challenge_projects.challenge_id = ?)", @challenge.id)
      else
        @user_projects = []
      end
    end

    def set_challenge_entrant
      if @challenge.disable_registration or @has_registered = (user_signed_in? and ChallengeRegistration.has_registered? @challenge, current_user)
        @current_entries = (user_signed_in? ? current_user.challenge_entries_for(@challenge) : {})
        @is_challenge_entrant = @current_entries.values.select{|v| v.any? }.any?
      end
    end

    def set_hello_world
      @show_hello_world = (!user_signed_in? and @challenge.judged?)
    end

    def set_layout
      if self.action_name.to_s.in? %w(show rules projects brief participants ideas idea idea_winners faq)
        'challenge'
      else
        current_layout
      end
    end
end
