class Project < ActiveRecord::Base
  belongs_to :user
  has_many :images, as: :attachable

  sanitize_text :description
  attr_accessible :description, :end_date, :name, :start_date, :images_attributes
  accepts_nested_attributes_for :images
  
  validates :name, :user_id, presence: true

  def image
    images.first
  end
end
