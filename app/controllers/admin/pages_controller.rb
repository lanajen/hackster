class Admin::PagesController < Admin::BaseController
  def root
  end

  def users
    @users = User.all
  end
end
