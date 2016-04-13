class Mouser::VendorsController < Mouser::BaseController
  PLATFORM_USER_NAMES = %w(intel texasinstruments stm seeed)

  def index
    @platforms = Platform.where(user_name: PLATFORM_USER_NAMES)
    @boards = [ 'Cypress', 'Diligent', 'Intel', 'NXP', 'Seeed Studio', 'ST Micro', 'TI', 'UDOO' ]
    @dates = [
      {date: 'May 1st', event: 'Project submissions open'},
      {date: 'May 15th', event: 'Project submissions close', sub_action: 'Prelimenary voting begins'},
      {date: 'May 31st', event: 'Project voting ends', sub_action: 'Vendor champions chosen'},
      {date: 'June 1st', event: 'Round 1 begins'},
      {date: 'June 10th', event: 'Round 2 begins'},
      {date: 'June 20th', event: 'Round 3 begins'},
      {date: 'June 30th', event: 'Competition ends', sub_action: 'Winner announced'}
    ]
  end

  def show
    @platform = Platform.find_by_user_name! params[:user_name]
  end
end