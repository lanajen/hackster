class ImageWidget < Widget
  define_attributes [:images_count]

  def self.model_name
    Widget.model_name
  end

  has_many :images, -> { order position: :asc }, as: :attachable, dependent: :destroy
  accepts_nested_attributes_for :images#, allow_destroy: true
  attr_accessible :images_attributes, :image_ids

  def to_text
    "<h3>#{name}</h3><div contenteditable='false' class='embed-frame' data-type='widget' data-widget-id='#{id}' data-caption=''></div>"
  end

  def to_tracker
    super.merge({
      images_count: images_count,
    })
  end
end
