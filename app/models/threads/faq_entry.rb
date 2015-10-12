class FaqEntry < Post
  sanitize_text :body
  register_sanitizer :trim_whitespace, :before_save, :body

  private
    def trim_whitespace text
      xml = Nokogiri::HTML::DocumentFragment.parse text
      first_text = -1
      last_text = 0

      ps = xml.children
      ps.each_with_index do |p, i|
        unless p.text.strip.gsub(/\u00a0/, '').empty?
          first_text = i if first_text == -1
          last_text = i
        end
      end

      out = ps.slice(first_text..last_text)
      out.map{|p| p.to_html }.join('') if out
    end
end