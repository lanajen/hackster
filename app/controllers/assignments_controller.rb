class AssignmentsController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :embed]
  before_filter :load_assignment, only: [:show, :embed, :link]
  before_filter :load_promotion, only: [:new, :create]
  load_and_authorize_resource only: [:edit, :update, :destroy]
  after_action :allow_iframe, only: :embed
  skip_before_filter :track_visitor, only: [:embed]
  skip_after_filter :track_landing_page, only: [:embed]
  layout 'group_shared'

  def show
    redirect_to promotion_path(@assignment.promotion) and return unless can? :read, @assignment
    title "#{@assignment.name} | #{@assignment.promotion.name}"
    @projects = @assignment.projects.for_thumb_display.order(:created_at).paginate(page: safe_page_params)
    if user_signed_in? and @assignment.submit_by_date.present? and can? :submit_project, @assignment
      @submit_date = @assignment.submit_by_date.in_time_zone(PDT_TIME_ZONE)
      @submission_status = if current_user.created_project_for_assignment?(@assignment)
        if current_user.submitted_project_to_assignment?(@assignment)
          'submitted'
        else
          'created'
        end
      else
        'none'
      end
    end
  end

  def embed
    surrogate_keys = [@assignment.record_key, "assignments/#{@assignment.id}/embed"]
    set_surrogate_key_header *surrogate_keys
    set_cache_control_headers

    @list_style = ([params[:list_style]] & ['_vertical', '_horizontal']).first || '_horizontal'
    # @list_style = '_horizontal'
    @projects = @assignment.projects.publyc.order(:created_at)
    render layout: 'embed'
  end

  def new
    @assignment = @promotion.assignments.new
    authorize! :create, @assignment

    render layout: 'application'
  end

  def create
    @assignment = @promotion.assignments.new params[:assignment]
    authorize! :create, @assignment

    if @assignment.save
      redirect_to assignment_path(@assignment), notice: "Assignment #{@assignment.name} was created."
    else
      render 'new', layout: 'application'
    end
  end

  def edit
    render layout: 'application'
  end

  def update
    if @assignment.update_attributes(params[:assignment])
      respond_to do |format|
        format.html { redirect_to @assignment, notice: 'Assignment updated.' }
        format.js do
          @promotion = GroupDecorator.decorate(@assignment.promotion)
        end

        track_event 'Updated assignment'
      end
    else
      respond_to do |format|
        format.html { render action: 'edit', layout: 'application' }
        format.js { render json: { assignment: @assignment.errors }, status: :unprocessable_entity }
      end
    end
  end

  def link
    @project = BaseArticle.find params[:project_id]
    @project.assignment = @assignment
    @project.save

    redirect_to @project, notice: "Your project has been added to #{@assignment.name}. Don't forget to submit it!"
  end

  private
    def load_promotion
      @group = @promotion = Promotion.joins(:course).where(groups: { user_name: params[:promotion_name] }, courses_groups: { user_name: params[:user_name] }).first!
    end
end