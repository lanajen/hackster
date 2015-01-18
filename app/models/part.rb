class Part < ActiveRecord::Base
  belongs_to :partable, polymorphic: true

  attr_accessible :name, :quantity, :unit_price, :vendor_link, :vendor_name,
    :vendor_sku, :partable_id, :partable_type, :mpn, :description, :position,
    :comment

  # validates :description, presence: true
  validate :ensure_not_empty
  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
  validates :description, :comment, length: { maximum: 255 }, allow_blank: true
  before_validation :ensure_protocol_for_vendor_link
  # validate :mpn_or_description_is_present?
  register_sanitizer :strip_whitespace, :before_validation, :mpn, :description
  # after_validation :compute_total_cost

  def self.with_sku
    where("parts.vendor_sku <> '' AND parts.vendor_sku IS NOT NULL")
  end

  def self.without_sku
    where("parts.vendor_sku = '' OR parts.vendor_sku IS NULL")
  end

  def compute_total_cost
    return false if unit_price.blank? or quantity.blank?
    self.total_cost = (unit_price * quantity.to_f).round(4)
  end

  def search_on_octopart
    return unless description.present? or mpn.present?

    keywords = mpn.presence || description

    if result = Octopart.search(keywords)
      self.vendor_link = result[:octopart_url]
      self.mpn = result[:mpn]
      self.vendor_name = result[:vendor_name] + ' (auto-matched)'
      self.unit_price = result[:price]
      self.total_cost = unit_price * quantity || 1
      result
    end
  end

  private
    def ensure_not_empty
      destroy unless description.present?
    end

    def ensure_protocol_for_vendor_link
      return if vendor_link.blank?

      self.vendor_link = 'http://' + vendor_link unless vendor_link =~ /\Ahttps?:/
    end

    def mpn_or_description_is_present?
      errors.add :description, 'cannot be blank if part # is blank' if mpn.blank? and description.blank?
    end

    def strip_whitespace text
      text.strip
    end
end
