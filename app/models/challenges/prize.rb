class Prize < ActiveRecord::Base
  belongs_to :challenge
  has_and_belongs_to_many :challenge_entries
  has_one :image, as: :attachable, dependent: :destroy
  has_one :project

  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  attr_accessible :name, :description, :position, :requires_shipping, :quantity,
    :cash_value, :link, :image_attributes

  accepts_nested_attributes_for :image

  def requires_shipping?
    requires_shipping
  end
end
