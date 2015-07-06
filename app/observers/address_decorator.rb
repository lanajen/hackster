class AddressDecorator < ApplicationDecorator
  def full
    model.completed? ? [full_name, address_line1, address_line2, "#{city}, #{state} #{zip}", country, "Phone: #{phone}"].select{|v| v.present? }.join('<br/>') : 'Not entered yet'
  end
end