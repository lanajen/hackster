class AssignmentsController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :embed]
  before_filter :load_assignment, only: [:show, :embed]
  before_filter :load_promotion, only: [:new, :create]
  load_and_authorize_resource only: [:edit, :update, :destroy]
  after_action :allow_iframe, only: :embed
  layout 'assignment'

  def show
    authorize! :read, @assignment
    @projects = @assignment.projects
  end

  def embed
    # @list_style = ([params[:list_style]] & ['', '_horizontal']).first || ''
    @list_style = '_horizontal'
    @projects = @assignment.projects
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
        format.js { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def load_assignment
      sql = "SELECT assignments.* FROM assignments INNER JOIN groups ON groups.id = assignments.promotion_id AND groups.type = 'Promotion' INNER JOIN groups courses_groups ON courses_groups.id = groups.parent_id AND courses_groups.type IN ('Course') WHERE groups.type IN ('Promotion') AND groups.user_name = ? AND courses_groups.user_name = ? AND assignments.id_for_promotion = ? ORDER BY assignments.id ASC LIMIT 1"
      @assignment = Assignment.find_by_sql([sql, params[:promotion_name], params[:user_name], params[:id]]).first
      raise ActiveRecord::RecordNotFound unless @assignment
      @promotion = @assignment.promotion
    end

    def load_promotion
      @promotion = Promotion.joins(:course).where(groups: { user_name: params[:promotion_name] }, courses_groups: { user_name: params[:user_name] }).first!
    end
end