class CoursesController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :load_course, only: [:show, :update]
  respond_to :html

  def show
    redirect_to promotion_path(@course.promotions.last)
  end

  private
    def load_course
      @course = load_with_user_name Course
    end
end