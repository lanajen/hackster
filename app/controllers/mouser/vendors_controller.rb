class Mouser::VendorsController < Mouser::BaseController
  PLATFORM_USER_NAMES = %w(intel texasinstruments stm seeed)

  def index
    @platforms = Platform.where(user_name: PLATFORM_USER_NAMES)
    @boards = [ 'Cypress', 'Diligent', 'Intel', 'NXP', 'Seeed Studio', 'ST Micro', 'TI', 'UDOO' ]
    @dates = [
      {date: 'May 1st', action: 'Project submissions open'},
      {date: 'May 15th', action: 'Project submissions close', subAction: 'Prelimenary voting begins'},
      {date: 'May 31st', action: 'Project voting ends', subAction: 'Vendor champions chosen'},
      {date: 'June 1st', action: 'Round 1 begins'},
      {date: 'June 10th', action: 'Round 2 begins'},
      {date: 'June 20th', action: 'Round 3 begins'},
      {date: 'June 30th', action: 'Competition ends', subAction: 'Winner announced'}
    ]
  end

  def show
    @platform = Platform.find_by_user_name! params[:user_name]
  end
end