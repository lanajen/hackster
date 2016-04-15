require 'yaml'

class Mouser::VendorsController < Mouser::BaseController
  PLATFORM_USER_NAMES = %w(cypress intel freescale texasinstruments stm seeed udoo) #missing Digilent

  def index
    @platforms = Platform.where(user_name: PLATFORM_USER_NAMES)
    @boards = [ 'Cypress', 'Digilent', 'Intel', 'NXP', 'Seeed Studio', 'ST Micro', 'Texas Instruments', 'UDOO' ] #Remove when done testing.
    @active_phase = redis.get('active_phase') || 0; # Set 'mouser:active_phase' to 0 in your redis db.

    mouser = YAML.load(File.open("#{Rails.root}/config/mouser.yml", 'r'))
    @phases = mouser['phases'].values
  end

  def show
    # @platforms = Platform.find_by_user_name! params[:user_name]
  end
end