class ImageWidget < Widget
  has_many :images, as: :attachable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true
  attr_accessible :images_attributes

  def help_text
    "Add as many images as you like."
  end
end
