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

  def to_text
    return '' unless content

    doc = Nokogiri::HTML::DocumentFragment.parse content

    # Replace all doubled-up <BR> tags with <P> tags
    doc.search('br').each do |n|
      if (n.next and n.next.name == 'br')
        n.next.remove
        n.replace('</p><p>')
      end
    end

    output = doc.to_html
    output = "<p>#{output}</p>" unless output.match /^<p>/
    "<h3>#{name}</h3>#{output}"
  end
end
