class Part < ActiveRecord::Base
  belongs_to :partable, polymorphic: true
  attr_accessible :name, :quantity, :unit_price, :vendor_link, :vendor_name,
    :vendor_sku, :partable_id, :partable_type
  after_validation :compute_total_cost

  private
    def compute_total_cost
      self.total_cost = (unit_price * quantity.to_f).round(2)
    end
end
