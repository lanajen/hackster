class Project < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks

  belongs_to :user
  has_and_belongs_to_many :followers, class_name: 'User', join_table: 'project_followers'
  has_many :blog_posts, as: :bloggable, dependent: :destroy
  has_many :images, as: :attachable, dependent: :destroy
  has_one :video, dependent: :destroy

  sanitize_text :description
  attr_accessible :description, :end_date, :name, :start_date, :images_attributes,
    :video_attributes, :current
  attr_accessor :current
  accepts_nested_attributes_for :images, :video, allow_destroy: true

  validates :name, :user_id, presence: true
  before_validation :check_if_current

  def image
    images.first
  end

  private
    def check_if_current
      self.end_date = nil if current
    end
end
