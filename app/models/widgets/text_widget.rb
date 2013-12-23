class TextWidget < Widget
  define_attributes [:content]

  def self.model_name
    Widget.model_name
  end

  def to_tracker
    super.merge({
      content_size: (content.present? ? content.length : 0),
    })
  end
end
