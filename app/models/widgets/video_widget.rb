class VideoWidget < Widget

  define_attributes [:caption]
  has_one :video, as: :recordable

  attr_accessible :video_attributes
  accepts_nested_attributes_for :video, allow_destroy: true

  def self.model_name
    Widget.model_name
  end
end
