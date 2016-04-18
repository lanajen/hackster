require 'yaml'

class Mouser::VendorsController < Mouser::BaseController
  before_filter :load_phases
  before_filter :load_vendors, only: [:index]

  def index
    @decorated_vendors = MouserVendorDecorator.decorate_collection(@vendors).map do |v|
      link = v.vendor_link
      board_image_link = v.board_image_link
      v = v.to_hash
      v[:vendor_link] = link
      v[:board_image_link] = board_image_link
      v
    end
  end

  def show
    @vendor = load_vendor params[:user_name]
    @next = load_vendor params[:user_name], 1
    @previous = load_vendor params[:user_name], -1
  end
end