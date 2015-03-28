class AddressDecorator < ApplicationDecorator
  def full
    model.completed? ? full_name + content_tag(:br) + address_line1 + content_tag(:br) + address_line2 + content_tag(:br) + "#{city}, #{state} #{zip}" + content_tag(:br) + country + content_tag(:br) + "Phone: #{phone}" : 'Not entered yet'
  end
end