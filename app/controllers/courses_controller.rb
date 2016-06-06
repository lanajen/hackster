class CoursesController < MainBaseController
  before_filter :authenticate_user!, except: [:show]
  before_filter :load_course, only: [:show, :update]
  layout 'group_shared', only: [:edit, :update, :show]
  respond_to :html

  def show
    title @course.name
    meta_desc "Join the course #{@course.name} on Hackster.io!"

    @promotions = @course.promotions.order(created_at: :desc)
    @projects = @course.projects.paginate(page: safe_page_params)

    render "groups/courses/show"
  end

  def new
    render "groups/courses/#{action_name}"
  end

  def update
    authorize! :update, @course

    if @course.update_attributes(params[:group])
      redirect_to @course, notice: 'Profile updated.'
    else
      @course.build_avatar unless @course.avatar
      render template: 'groups/shared/edit', layout: current_layout
    end
  end

  private
    def load_course
      @group = @course = Course.includes(:university).where(groups: { user_name: params[:user_name] }, universities_groups: { user_name: params[:uni_name] }).first!
    end
end