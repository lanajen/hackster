def clean_inline_text string
  strings = []
  cur = ''
  in_tag = nil
  tag_opening = nil

  string.gsub! /\s*(<br\/?>\s*)+<br\/?>\s*/i, '<br><br>'

  string.split('').each do |char|
    cur << char
    if in_tag.present?
      if cur.match Regexp.new("</#{in_tag}>")
        strings << "#{tag_opening}#{cur}"
        cur = ''
        in_tag = nil
      end
    else
      regex = /(<(h3|h4|h5|h6|ul|div|ol|pre|p|blockquote|table|tbody|th|tr|thead|tfoot|td|li)(\s+[^>]+)?>)/i
      if cur.match regex
        in_tag = $2
        tag_opening = $1
        cur.gsub! regex, ''
        if cur.present?
          s = cur.gsub /<br\/?>\s*<br\/?>/i, '</p><p>'
          strings << ('<p>' + s + '</p>')
        end
        cur = ''
      end
    end
  end
  if cur.present?
    s = cur.gsub /<br\/?>\s*<br\/?>/i, '</p><p>'
    strings << ('<p>' + s + '</p>')
  end

  final = strings.join('')
  final.gsub!(/([^p])>(<br>)+/i){|m| $1 + '>' }
  final.gsub!(/(<br>)+<\/[^p]/i){|m| '<' + $1 }
  final.gsub! /<p><\/p>/i, ''
  final
end

def cleanup_divs html
  d = Nokogiri::HTML::DocumentFragment.parse html
  d.css('div').each do |el|
    if el['class'] !~ /embed-frame/
      2.times do
        node = Nokogiri::XML::Node.new 'br', d
        el.add_previous_sibling node
      end
      el.children.each do |c|
        el.add_previous_sibling c
      end
      if el.next and el.next.name != 'div'
        2.times do
          node = Nokogiri::XML::Node.new 'br', d
          el.add_previous_sibling node
        end
      end
      el.remove
    else
      el.children.each do |c|
        c.remove
      end
    end
  end
  d.to_s
end

dif = []
BaseArticle.find_each do |project|
  next if project.description.blank?

  text = cleanup_divs project.description

  text = clean_inline_text text

  if project.description != text
    project.update_attribute :desc_backup, project.description
    project.update_column :description, text
    dif << project
  end
end