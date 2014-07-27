class Part < ActiveRecord::Base
  belongs_to :partable, polymorphic: true

  attr_accessible :name, :quantity, :unit_price, :vendor_link, :vendor_name,
    :vendor_sku, :partable_id, :partable_type, :mpn, :description, :position

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
  validates :description, length: { maximum: 255 }, allow_blank: true
  # validate :mpn_or_description_is_present?
  register_sanitizer :strip_whitespace, :before_validation, :mpn, :description
  # after_validation :compute_total_cost

  def compute_total_cost
    return false if unit_price.blank? or quantity.blank?
    self.total_cost = (unit_price * quantity.to_f).round(4)
  end

  private
    def mpn_or_description_is_present?
      errors.add :description, 'cannot be blank if part # is blank' if mpn.blank? and description.blank?
    end

    def strip_whitespace text
      text.strip
    end
end
