class MouserVendorDecorator < ApplicationDecorator
  def board_image_link
    h.asset_url model.board_image_url
  end

  def vendor_link
    h.mouser_vendor_path model.user_name
  end
end