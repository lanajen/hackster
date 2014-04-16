class AssignmentsController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :embed]
  before_filter :load_assignment, only: [:show, :embed, :link]
  before_filter :load_promotion, only: [:new, :create]
  load_and_authorize_resource only: [:edit, :update, :destroy]
  after_action :allow_iframe, only: :embed
  layout 'assignment'

  def show
    redirect_to promotion_path(@assignment.promotion) and return unless can? :read, @assignment
    title "#{@assignment.name} | #{@assignment.promotion.name}"
    @projects = @assignment.projects.order(:created_at)
  end

  def embed
    # @list_style = ([params[:list_style]] & ['', '_horizontal']).first || ''
    @list_style = '_horizontal'
    @projects = @assignment.projects.order(:created_at)
    render layout: 'embed'
  end

  def new
    @assignment = @promotion.assignments.new
    authorize! :create, @assignment

    render layout: 'promotion'
  end

  def create
    @assignment = @promotion.assignments.new params[:assignment]
    authorize! :create, @assignment

    if @assignment.save
      redirect_to assignment_path(@assignment), notice: "Assignment #{@assignment.name} was created."
    else
      render 'new', layout: 'promotion'
    end
  end

  def edit
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
        format.html { render action: 'edit' }
        format.js { render json: { assignment: @assignment.errors }, status: :unprocessable_entity }
      end
    end
  end

  def link
    @project = Project.find params[:project_id]
    @project.assignment = @assignment
    @project.save

    redirect_to assignment_path(@assignment), notice: "Your project has been added to #{@assignment.name}."
  end

  private
    def load_promotion
      @promotion = Promotion.joins(:course).where(groups: { user_name: params[:promotion_name] }, courses_groups: { user_name: params[:user_name] }).first!
    end
end