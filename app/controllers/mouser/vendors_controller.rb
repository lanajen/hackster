class Mouser::VendorsController < Mouser::BaseController
  PLATFORM_USER_NAMES = %w(intel texasinstruments stm seeed)

  def index
    @platforms = Platform.where(user_name: PLATFORM_USER_NAMES)
  end

  def show
    @platform = Platform.find_by_user_name params[:user_name]
  end
end