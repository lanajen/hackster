class Address < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper

  belongs_to :addressable, polymorphic: true

  attr_accessible :full_name, :address_line1, :address_line2, :state, :city,
    :country, :zip, :phone, :default
  validates :full_name, :address_line1, :city, :zip, :country, :phone, presence: true
  validates :full_name, :address_line1, :address_line2, :city, :state, :zip, :country, :phone, length: { maximum: 255 }

  register_sanitizer :strip_tags, :before_save, :full_name, :address_line1,
    :address_line2, :state, :city, :country, :zip, :phone

  def self.default
    where(default: true).where.not(deleted: true).first
  end

  def self.visible
    where deleted: false
  end

  def completed?
    full_name.present?
  end

  def full
    "#{full_name}, #{address_line1}, #{address_line2}, #{city}, #{state}, #{zip}, #{country} / #{phone}"
  end

  private
    def strip_tags text
      sanitize(text, tags: [])
    end
end
