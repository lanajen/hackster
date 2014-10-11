class Address < ActiveRecord::Base
  belongs_to :addressable, polymorphic: true

  attr_accessible :full_name, :address_line1, :address_line2, :state, :city,
    :country, :zip, :phone
  validates :full_name, :address_line1, :city, :zip, :country, :phone, presence: true
  validates :full_name, :address_line1, :address_line2, :city, :state, :zip, :country, :phone, length: { maximum: 255 }

  def completed?
    full_name.present?
  end

  def full
    "#{full_name}, #{address_line1}, #{address_line2}, #{city}, #{state}, #{zip}, #{country} / #{phone}"
  end
end
