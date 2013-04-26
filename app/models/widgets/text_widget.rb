class TextWidget < Widget
  define_attributes [:content]

  def content_definition
    {
      type: :text,
      as: :text,
    }
  end

  def help_text
    "You can use HTML tags in the content. Try <a> for links!"
  end
end
