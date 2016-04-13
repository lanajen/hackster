class Mouser::VendorsController < Mouser::BaseController
  PLATFORM_USER_NAMES = %w(cypress intel freescale texasinstruments stm seeed udoo) #missing Digilent

  def index
    @platforms = Platform.where(user_name: PLATFORM_USER_NAMES)
    @boards = [ 'Cypress', 'Digilent', 'Intel', 'NXP', 'Seeed Studio', 'ST Micro', 'Texas Instruments', 'UDOO' ] #Remove when done testing.
  end

  def show
    @platform = Platform.find_by_user_name! params[:user_name]
  end
end