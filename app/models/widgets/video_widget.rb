class VideoWidget < Widget

  def self.model_name
    Widget.model_name
  end

  has_one :video, as: :recordable

  attr_accessible :video_attributes
  accepts_nested_attributes_for :video, allow_destroy: true
end
