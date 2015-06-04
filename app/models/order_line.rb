class OrderLine < ActiveRecord::Base
  belongs_to :order
  belongs_to :store_product

  # validates :order, :store_product, presence: true

  attr_accessible :store_product_id

  validate :ensure_store_product

  private
    # for admin
    def ensure_store_product
      destroy unless store_product_id.present?
    end
end
