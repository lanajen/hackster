class AddressDecorator < ApplicationDecorator
  def full
    model.completed? ? [full_name, address_line1, address_line2, "#{city}, #{state} #{zip}", country, "Phone: #{phone}"].select{|v| v.present? }.join('<br/>') : 'Not entered yet'
  end

  def full_long
    ["<strong>Name:</strong> #{full_name}", "<strong>Address line 1:</strong> #{address_line1}", "<strong>Address line 2:</strong> #{address_line2}", "<strong>City:</strong> #{city}", "<strong>State:</strong> #{state}", "<strong>Zip:</strong> #{zip}", "<strong>Country:</strong> #{country}", "<strong>Phone:</strong> #{phone}"].select{|v| v.present? }.join('<br/>')
  end

  def one_line
    model.completed? ? [full_name, address_line1, address_line2, "#{city}, #{state} #{zip}", country, "Phone: #{phone}"].select{|v| v.present? }.join(', ') : 'Not entered yet'
  end
end