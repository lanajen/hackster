class Mouser::VendorsController < Mouser::BaseController
  before_filter :load_phases
  before_filter :load_vendors, only: [:index]

  def index
  end

  def show
    @vendor = load_vendor params[:user_name]
    @next = load_vendor params[:user_name], 1
    @previous = load_vendor params[:user_name], -1
  end
end