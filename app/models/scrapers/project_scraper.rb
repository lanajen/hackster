class ProjectScraper
  include ScraperUtils

  def self.scrape page_url
    s = new
    url = File.join(Rails.root, 'app/models/scrapers/maker.html')
    content = s.read_file url
    # content = s.fetch_page page_url

    s.document(content).to_project
  end

  def document content=nil
    Document.new(content)
  end

  # def initialize page_url
  #   @page_url = page_url
  # end

  class Document
    include ScraperUtils

    LINK_REGEXP = {
      /github\.com/ => 'GithubWidget.new(repo:"|href|",name:"Github repo")',
      # /oshpark\.com/ => 'GithubWidget',
      /upverter\.com/ => 'UpverterWidget.new(link:"|href|",name:"Schematics on Upverter")',
      /youtube\.com/ => 'VideoWidget.new(video_attributes:{link:"|href|"},name:"Demo video")',
      /youtu\.be/ => 'VideoWidget.new(video_attributes:{link:"|href|"},name:"Demo video")',
      /vimeo\.com/ => 'VideoWidget.new(video_attributes:{link:"|href|"},name:"Demo video")',
      /tindie\.com/ => 'BuyWidget.new(link:"|href|",name:"Where to buy")',
    }

    def initialize content
      @parsed = Nokogiri::HTML(content)
    end

    def to_project
      project = Project.new private: true
      widgets = []

      article = @parsed.at_css('article') || @parsed.at_css('.post') || @parsed

      {
        'a' => 'href',
        'iframe' => 'src',
      }.each do |el, attr|
        article.css(el).each do |link|
          LINK_REGEXP.each do |regexp, command|
            if link[attr] =~ Regexp.new(regexp)
              command.gsub!(/\|href\|/, link[attr])
              widget = eval command
              widgets << widget
              break
            end
          end
        end
      end

      project.name = article.at_css('.entry-title').try(:text) || article.css('h1').last.try(:text) || article.at_css('h2').try(:text) || @parsed.title

      tags = article.css('[rel=category]') + article.css('[rel=tag]') + article.css('[rel="category tag"]')
      project.product_tags_string = tags.map{|a| a.text }.join(',')

      image_widget = ImageWidget.new name: 'Photos'
      article.css('img').each_with_index do |img, i|
        image_widget.images.new(remote_file_url: img['src'], title: img['title'], position: i)
      end
      widgets << image_widget if image_widget.images.any?

      if img = article.at_css('img')
        project.build_cover_image remote_file_url: img['src']
      end

      # article.at_css('.entry-content').try(:inner_html) ||  # includes share tools
      raw_text = article.css('p').map{|p| p.to_html }.join('')
      sanitized_text = Sanitize.clean(raw_text, Sanitize::Config::BASIC)
      text = Nokogiri::HTML(sanitized_text)
      text.css('a').find_all.each{|el| el.remove if el.content.strip.blank? }
      text.css('p').find_all.each{|el| el.remove if el.content.strip.blank? }
      text = Sanitize.clean(text.to_html, Sanitize::Config::BASIC)
      widgets << TextWidget.new(content: text, name: 'About')

      widget_col = 1
      widget_row = 1
      count = 0
      widgets.each do |widget|
        project.widgets << widget
        widget.position = "#{widget_col}.#{widget_row}"
        if count.even?
          widget_col += 1
        else
          widget_row += 1
        end
        count += 1
      end

      project
    end
  end
end