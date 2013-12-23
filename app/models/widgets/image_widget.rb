class ImageWidget < Widget
  define_attributes [:images_count]

  def self.model_name
    Widget.model_name
  end

  has_many :images, -> { order position: :asc }, as: :attachable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true
  attr_accessible :images_attributes, :image_ids

  def to_tracker
    super.merge({
      images_count: images_count,
    })
  end
end
