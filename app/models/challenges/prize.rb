class Prize < ActiveRecord::Base
  belongs_to :challenge
  has_and_belongs_to_many :entries, class_name: 'ChallengeEntry'
  has_many :projects, through: :entries
  has_one :image, as: :attachable, dependent: :destroy

  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  attr_accessible :name, :description, :position, :requires_shipping, :quantity,
    :cash_value, :link, :image_attributes

  accepts_nested_attributes_for :image

  register_sanitizer :trim, :before_save
  trim_text :name, :description

  def requires_shipping?
    requires_shipping
  end

  def trim text
    text.strip if text
  end
end
