class Part < ActiveRecord::Base
  belongs_to :partable, polymorphic: true
  attr_accessible :name, :quantity, :unit_price, :vendor_link, :vendor_name,
    :vendor_sku, :partable_id, :partable_type
  validates :unit_price, :quantity, presence: true
  after_validation :compute_total_cost

  private
    def compute_total_cost
      return false if unit_price.blank? or quantity.blank?
      self.total_cost = (unit_price * quantity.to_f).round(2)
    end
end
