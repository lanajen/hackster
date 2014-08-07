class VideoWidget < Widget

  define_attributes [:caption]
  has_one :video, as: :recordable

  attr_accessible :video_attributes
  accepts_nested_attributes_for :video, allow_destroy: true

  def self.model_name
    Widget.model_name
  end

  def to_text
    if video and video.link
      caption_text = caption.present? ? "<p>#{caption}</p>" : ''
      "<h3>#{name}</h3>#{caption_text}<div contenteditable='false' class='embed-frame' data-type='url' data-url='#{video.link}' data-caption=''></div>"
    else
      ''
    end
  end
end
