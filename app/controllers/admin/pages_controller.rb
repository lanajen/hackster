class Admin::PagesController < Admin::BaseController
  def projects
    @projects = Project.order(:created_at)
  end

  def root
  end

  def users
    @users = User.order(:created_at)
  end
end
