class Address < ActiveRecord::Base
  belongs_to :addressable, polymorphic: true

  attr_accessible :full_name, :address_line1, :address_line2, :state, :city,
    :country, :zip, :phone
end
