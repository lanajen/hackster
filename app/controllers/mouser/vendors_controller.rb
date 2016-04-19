require 'yaml'

class Mouser::VendorsController < Mouser::BaseController
  before_filter :load_phases
  before_filter :load_vendors

  def index
    @decorated_vendors = build_decorated_vendors
  end

  def show
    @decorated_vendors = build_decorated_vendors
    @vendor = load_vendor params[:user_name]
    @next = load_vendor params[:user_name], 1
    @previous = load_vendor params[:user_name], -1
  end

  private
    def build_decorated_vendors
      MouserVendorDecorator.decorate_collection(@vendors).map do |v|
        v[:logo_url] = v.logo_link
        v[:board_image_url] = v.board_image_link
        v = v.to_hash
      end
    end

end