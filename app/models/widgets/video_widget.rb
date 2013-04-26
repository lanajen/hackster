class VideoWidget < Widget
  has_one :video, as: :recordable

  attr_accessible :video_attributes
  accepts_nested_attributes_for :video

  def help_text
    "Add a video from Youtube or Vimeo."
  end
end
