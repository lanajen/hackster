class CoursesController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :load_course, only: [:show, :update]
  # layout 'course', only: [:edit, :update, :show]
  respond_to :html

  def show
    redirect_to course_promotion_path(@course.user_name, @course.promotions.last.try(:user_name))
  end

  # def show
  #   authorize! :read, @course
  #   title @course.name
  #   meta_desc "#{@course.name} students are learning on Hackster.io. Join them!"
  #   # @broadcasts = @course.broadcasts.limit 20
  #   @projects = @course.projects

  #   render "groups/courses/#{self.action_name}"
  # end

  # def edit
  #   @course = Course.find(params[:id])
  #   authorize! :update, @course
  #   @course.build_avatar unless @course.avatar

  #   render "groups/courses/#{self.action_name}"
  # end

  # def update
  #   authorize! :update, @course
  #   old_course = @course.dup

  #   if @course.update_attributes(params[:group])
  #     respond_to do |format|
  #       format.html { redirect_to @course, notice: 'Profile updated.' }
  #       format.js do
  #         @course.avatar = nil unless @course.avatar.try(:file_url)
  #         # if old_group.interest_tags_string != @course.interest_tags_string or old_group.skill_tags_string != @course.skill_tags_string
  #         if old_course.user_name != @course.user_name
  #           @refresh = true
  #         end

  #         render "groups/courses/#{self.action_name}"
  #       end

  #       track_event 'Updated course'
  #     end
  #   else
  #     @course.build_avatar unless @course.avatar
  #     respond_to do |format|
  #       format.html { render action: 'edit' }
  #       format.js { render json: @course.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  private
    def load_course
      @course = load_with_user_name Course
    end
end