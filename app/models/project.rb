class Project < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :followers, class_name: 'User', join_table: 'project_followers'
  has_many :images, as: :attachable, dependent: :destroy
  has_one :video, dependent: :destroy

  sanitize_text :description
  attr_accessible :description, :end_date, :name, :start_date, :images_attributes,
    :video_attributes
  accepts_nested_attributes_for :images, :video, allow_destroy: true

  validates :name, :user_id, presence: true

  def image
    images.first
  end
end
