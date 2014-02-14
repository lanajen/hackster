class AssignmentsController < ApplicationController
  before_filter :load_assignment, only: [:show]
  load_and_authorize_resource only: [:edit, :update, :destroy]
  layout 'assignment'

  def show
    @projects = @assignment.projects
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
end