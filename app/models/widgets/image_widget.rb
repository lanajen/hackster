class ImageWidget < Widget

  def self.model_name
    Widget.model_name
  end
  
  has_many :images, as: :attachable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true
  attr_accessible :images_attributes

  def help_text
    "Add as many images as you like."
  end
end
