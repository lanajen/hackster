class Admin::PagesController < Admin::BaseController
  def projects
    @projects = Project.all
  end
  
  def root
  end

  def users
    @users = User.all
  end
end
