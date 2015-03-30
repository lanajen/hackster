class AddressDecorator < ApplicationDecorator
  def full
    model.completed? ? full_name + h.content_tag(:br) + address_line1 + h.content_tag(:br) + address_line2 + h.content_tag(:br) + "#{city}, #{state} #{zip}" + h.content_tag(:br) + country + h.content_tag(:br) + "Phone: #{phone}" : 'Not entered yet'
  end
end