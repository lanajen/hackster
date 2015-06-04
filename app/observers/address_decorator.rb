class AddressDecorator < ApplicationDecorator
  def full
    model.completed? ? full_name + '<br/>' + address_line1 + '<br/>' + address_line2 + '<br/>' + "#{city}, #{state} #{zip}" + '<br/>' + country + '<br/>' + "Phone: #{phone}" : 'Not entered yet'
  end
end