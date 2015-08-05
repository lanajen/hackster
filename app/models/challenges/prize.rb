class Prize < ActiveRecord::Base
  belongs_to :challenge
  has_and_belongs_to_many :challenge_entries
  has_one :image, as: :attachable, dependent: :destroy
  has_one :project

  attr_accessible :name, :description, :position, :requires_shipping, :quantity,
    :cash_value, :link

  def requires_shipping?
    requires_shipping
  end
end
