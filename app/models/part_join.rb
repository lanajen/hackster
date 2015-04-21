class PartJoin < ActiveRecord::Base
  belongs_to :part
  belongs_to :partable, polymorphic: true

  attr_accessible :part_id, :partable_id, :partable_type, :quantity, :comment,
    :total_cost, :position, :part_attributes

  accepts_nested_attributes_for :part
  # after_validation :compute_total_cost
  validates :quantity, numericality: { greater_than: 0 }
  validates :part_id, uniqueness: { scope: [:partable_type, :partable_id] }
  validates :part_id, :partable_id, :partable_type, presence: true

  register_sanitizer :strip_whitespace, :before_validation, :comment

  def compute_total_cost
    return false if unit_price.blank? or quantity.blank?
    self.total_cost = (unit_price * quantity.to_f).round(4)
  end

  def part
    @part ||= if super
      super
    else
      Part.new
    end
  end

  def unit_price
    part.unit_price
  end

  private
    def strip_whitespace text
      text.try(:strip)
    end
end
