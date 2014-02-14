class University < ActiveRecord::Base
  has_many :courses_universities
  has_many :courses, through: :courses_universities
  has_one :logo, as: :attachable, class_name: 'Avatar', dependent: :destroy

  validates :name, presence: true

  attr_accessible :name, :city, :country
end
