class TextWidget < Widget
  define_attributes [:content]

  def self.model_name
    Widget.model_name
  end

  def content_definition
    {
      type: :text,
      as: :text,
    }
  end

  def help_text
    "You can use HTML tags in the content. Try <a> for links!"
  end

  def to_tracker
    super.merge({
      content_size: (content.present? ? content.length : 0),
    })
  end
end
