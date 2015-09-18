class ChallengesController < ApplicationController
  before_filter :authenticate_user!, only: [:edit, :update, :update_workflow]
  before_filter :load_challenge, only: [:show, :brief, :projects, :participants, :update]
  before_filter :authorize_and_set_cache, only: [:show, :brief, :projects]
  before_filter :load_platform, only: [:show, :brief, :projects, :participants]
  before_filter :load_and_authorize_challenge, only: [:enter, :update_workflow]
  before_filter :set_challenge_entrant, only: [:show, :brief, :projects, :participants]
  before_filter :load_user_projects, only: [:show, :brief, :projects, :participants]
  load_and_authorize_resource only: [:edit, :update]
  layout :set_layout
  skip_before_filter :track_visitor, only: [:show, :brief, :projects]
  skip_after_filter :track_landing_page, only: [:show, :brief, :projects]

  def index
    title 'Hardware challenges'
    meta_desc "Build the best hardware projects and win awesome prizes!"

    @active_challenges = Challenge.public.active.ends_first
    @coming_challenges = Challenge.public.coming.starts_first
    @past_challenges = Challenge.public.past.ends_last
  end

  def show
    title @challenge.name
    # @embed = Embed.new(url: @challenge.video_link)

    if @challenge.ended? and !@challenge.disable_projects_tab
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
    title "#{@challenge.name} projects"
    load_projects
  end

  def participants
    title "#{@challenge.name} participants"
    respond_to do |format|
      format.html do
        @participants = @challenge.registrants.reorder("challenge_registrations.created_at DESC").paginate(page: safe_page_params)
      end
      format.csv do
        authorize! :admin, @challenge
        @registrations = @challenge.registrations.includes(:user).order("users.full_name ASC")
        file_name = FileNameGenerator.new(@challenge.name)
        headers['Content-Disposition'] = "attachment; filename=\"#{file_name}.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def update
    authorize! :update, @challenge
    if @challenge.update_attributes(params[:challenge])
      redirect_to @challenge, notice: 'Changes saved.'
    else
      render 'edit'
    end
  end

  def update_mailchimp
    MailchimpWorker.perform_async 'sync_challenge', @challenge.id
    redirect_to @challenge, notice: 'Your Mailchimp will be updated shortly.'
  end

  def update_workflow
    if @challenge.send "#{params[:event]}!"
      flash[:notice] = "Challenge #{event_to_human(params[:event])}."
      redirect_to @challenge
    else
      # flash[:error] = "Couldn't #{params[:event].gsub(/_/, ' ')} challenge, please try again or contact an admin."
      render :edit
    end
  end

  def unlock
    @challenge = Challenge.find params[:id]
    redirect_to @challenge and return unless @challenge.password_protect?

    if key = @challenge.unlock(params[:password])
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

      if user_signed_in?
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
      @challenge = Challenge.find_by_slug! params[:slug]
      @challenge = @challenge.decorate
    end

    def load_and_authorize_challenge
      @challenge = Challenge.find params[:id]
      authorize! self.action_name.to_sym, @challenge
    end

    def load_platform
      @platform = @challenge.platform.try(:decorate)
    end

    def load_projects
      per_page = Challenge.per_page
      if @challenge.judged?
        @winning_entries = @challenge.entries.winning.includes(:project).inject([]){|mem, e| mem << e unless mem.select{|m| m.project_id == e.project_id }.any?; mem }
        @winning_entries_count = @winning_entries.count
        @other_projects = @challenge.projects.reorder('').most_respected.where.not(challenge_projects: { id: @winning_entries.map(&:id) }).for_thumb_display.paginate(page: safe_page_params, per_page: per_page)
      else
        per_page = per_page - 1 if @challenge.open_for_submissions? and !@is_challenge_entrant
        @projects = @challenge.projects.valid.reorder("(CASE WHEN projects.workflow_state = 'approved' THEN 1 ELSE 2 END) ASC, challenge_projects.created_at DESC").for_thumb_display.paginate(page: safe_page_params, per_page: per_page)
      end
    end

    def load_user_projects
      if user_signed_in? and @challenge.open_for_submissions?
        @user_projects = current_user.projects.own.self_hosted.where("NOT projects.id IN (SELECT projects.id FROM projects INNER JOIN challenge_projects ON projects.id = challenge_projects.project_id WHERE challenge_projects.challenge_id = ?)", @challenge.id)
        @user_projects = @user_projects.select{|p| p.is_idea? } if @challenge.project_ideas
      else
        @user_projects = []
      end
    end

    def set_challenge_entrant
      if @challenge.disable_registration or @has_registered = (user_signed_in? and ChallengeRegistration.has_registered? @challenge, current_user)
        @current_entries = (user_signed_in? ? current_user.challenge_entries_for(@challenge) : [])
        @is_challenge_entrant = @current_entries.any?
      end
    end

    def set_layout
      if self.action_name.to_s.in? %w(show rules projects brief participants)
        'challenge'
      else
        current_layout
      end
    end
end