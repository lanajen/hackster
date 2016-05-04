class MouserVendorDecorator < ApplicationDecorator
  def board_image_link
    h.asset_url model.board_image_url
  end

  def logo_link
    h.asset_url model.logo_url
  end
end