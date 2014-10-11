module ScraperStrategies
  class Udoo < Base
    def to_project
      puts 'Converting to project...'

      @project = Project.new private: true
      @widgets = []
      @embedded_urls = {}
      Embed::LINK_REGEXP.values.each{|provider| @embedded_urls[provider.to_s] = [] }

      @article = select_article
      @project.name = extract_title

      before_parse

      normalize_links
      parse_cover_image
      parse_comments
      format_text
      parse_images
      parse_embeds
      parse_files
      parse_code
      clean_up_formatting

      after_parse

      @project.description = @article.children.to_s

      # puts @project.description

      @project.give_embed_style!

      @project
    end

    private
      def before_parse
        @project.guest_name = @parsed.search("[text()*='Name:']").first.next.text.strip
        @project.tech_tags_string = 'Udoo'
        @project.website = @parsed.search("[text()*='Project URL:']").first.try(:next_element).try(:text).try(:strip)

        super
      end

      def extract_title
        @parsed.at_css('h1').text.strip
      end

      def select_article
        els = []

        els += @parsed.css('.slides img, .slides iframe').map{|el| el.to_s }

        desc = @parsed.search("[text()*='Description:']").first
        els << "<p>#{desc.next.text.strip}</p>"
        if el = desc.parent.next_element
          els << el.to_s
          while el = el.next_element
            els << el.to_s if el.to_s.present?
          end
        end

        Nokogiri::HTML::DocumentFragment.parse els.join('')
      end
  end
end