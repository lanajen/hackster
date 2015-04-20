class PartJoin < ActiveRecord::Base
  belongs_to :part
  belongs_to :partable, polymorphic: true

  attr_accessible :part_id, :partable_id, :partable_type, :quantity, :comment,
    :total_cost, :position, :part_attributes#, :name, :vendor_link, :vendor_sku

  accepts_nested_attributes_for :part
  # after_validation :compute_total_cost
  validates :quantity, numericality: { greater_than: 0 }
  validates :comment, length: { maximum: 255 }, allow_blank: true
  validates :part_id, uniqueness: { scope: [:partable_type, :partable_id] }
  validates :part_id, :partable_id, :partable_type, presence: true  # put this back when full system implemented

  register_sanitizer :strip_whitespace, :before_validation, :comment

  # temporary until full system is implemented
  # after_initialize :ensure_part
  # before_save :save_part

  # def save_part
  #   unless part.persisted?
  #     part.save
  #     self.part_id = part.id
  #   end
  # end

  # def ensure_part
  #   self.part ||= build_part
  # end
  # end temp

  def compute_total_cost
    return false if unit_price.blank? or quantity.blank?
    self.total_cost = (unit_price * quantity.to_f).round(4)
  end

  # def name=val
  #   self.part.name = val
  # end

  # def name
  #   part.try(:name)
  # end

  def part
    @part ||= if super
      super
    else
      Part.new
    end
  end

  # def vendor_link=val
  #   self.part.store_link = val
  # end

  # def vendor_link
  #   part.try(:store_link) || part.try(:vendor_link)
  # end

  # def vendor_sku=val
  #   self.part.vendor_sku = val
  # end

  # def vendor_sku
  #   part.try(:vendor_sku)
  # end

  def unit_price
    part.unit_price
  end

  private
    def strip_whitespace text
      text.try(:strip)
    end
end
