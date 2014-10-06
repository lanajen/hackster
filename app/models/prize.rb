class Prize < ActiveRecord::Base
  belongs_to :contest
  has_one :image, as: :attachable, dependent: :destroy
  has_one :project

  attr_accessible :name, :description, :position
end
