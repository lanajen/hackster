class GradesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_assignment
  before_filter :load_group, only: [:edit, :update]
  before_filter :load_project
  before_filter :load_user

  def index
    if @assignment
      @promotion = @assignment.promotion
      render 'grades/assignments/index', layout: 'assignment'
    else
      @grades = current_user.all_grades
      render 'grades/users/index'
    end
  end

  def edit
    if @assignment
      if @assignment.grading_type.present?
        if @project.nil?
          @project = @assignment.projects.where(graded: false).first
          redirect_to assignment_edit_grade_path(@assignment, @project) and return if @project
        end

        if @project
          case @assignment.grading_type
          when 'individual'
            if @gradable.nil?
              @gradable = @project.users.includes(:grades).references(:grades).where(grades: { gradable_id: nil }).first
              redirect_to assignment_edit_grade_path(@assignment, @project, @gradable.id) and return if @gradable
            end
            type = 'User'
          when 'group'
            @gradable = @project.team if @project
            type = 'Group'
          end
          @grade = Grade.where(gradable_id: @gradable.id, gradable_type: type, project_id: @project.id).first_or_initialize if @gradable
        end

        redirect_to assignment_grades_path(@assignment) unless @grade
      else
        redirect_to assignment_grades_path(@assignment)
      end
    elsif @group
      @event = @group
      render 'grades/events/edit', layout: 'event'
    end
  end

  def update
    if params[:assignment]
      @assignment.update_attributes params[:assignment]
      redirect_to assignment_edit_grade_path(@assignment)
    elsif params[:grade]
      @grade = Grade.where(gradable_id: params[:grade][:gradable_id], gradable_type: params[:grade][:gradable_type], project_id: params[:grade][:project_id]).first_or_initialize
      @grade.assign_attributes params[:grade]
      @grade.user = current_user
      if @grade.save
        @project = @grade.project
        if (@assignment.grading_type == 'individual' and @project.users.includes(:grades).references(:grades).where(grades: { gradable_id: nil }).empty?) or @assignment.grading_type == 'group'
          @project.update_attribute :graded, true
          @assignment.update_attribute :graded, true if @assignment.projects.where(graded: false).empty?
        end
        redirect_to assignment_edit_grade_path(@assignment)
      else
        @project = @grade.project
        @gradable = @grade.gradable
        render 'edit'
      end
    elsif @group
      @group.assign_attributes params[:group]
      @group.awards.each do |award|
        award.gradable = @group if award.gradable.nil?
        award.user = current_user if award.user_id.blank?
      end
      if @group.save
        redirect_to group_path(@group), notice: "Awards saved."
      else
        @event = @group
        render 'grades/events/edit', layout: 'event'
      end
    end
  end

  private
    def load_assignment
      if params[:assignment_id]
        @assignment = Assignment.find params[:assignment_id]
        authorize! :manage, @assignment
      end
    end

    def load_group
      if params[:group_id]
        @group = Group.find params[:group_id]
        authorize! :manage, @group
      end
    end

    def load_project
      @project = Project.find params[:project_id] if params[:project_id]
    end

    def load_user
      @gradable = User.find params[:user_id] if params[:user_id]
    end
end