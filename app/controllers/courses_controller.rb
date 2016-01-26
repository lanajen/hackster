class CoursesController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :load_course, only: [:show]
  respond_to :html

  def show
    redirect_to promotion_path(@course.promotions.last)
  end

  def new
    render "groups/courses/#{action_name}"
  end

  private
    def load_course
      @course = load_with_user_name Course
    end
end