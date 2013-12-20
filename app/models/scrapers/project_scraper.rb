# use a CSV to store all the data
# make interface to go through all articles and #1 find if I want them and #2 get the correct URL

class ProjectScraper
  include ScraperUtils

  def document content=nil
    Document.new(content)
  end

  def self.work
    s = new('')
    url = File.join(Rails.root, 'app/models/scrapers/maker.html')
    content = s.read_file url
    s.document(content).to_project
  end

  def initialize page_url
    @page_url = page_url
  end

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
      project = Project.new
      widgets = []

      article = @parsed.at_css('article') || @parsed

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

      h1 = article.css('h1')
      project.name = if h1.any?
        h1.last.text
      else
        @parsed.title
      end

      project.product_tags_string = article.css('[rel=category]').map{|a| a.text }.join(',')

      image_widget = ImageWidget.new
      article.css('img').each do |img|
        image_widget.images.new(remote_file_url: img['src'], title: img['title'] || img['alt'], name: 'Photos')
      end
      widgets << image_widget if image_widget.images.any?

      text = article.css('p').map{|p| p.to_html }.join('')
      widgets << TextWidget.new(content: Sanitize.clean(text, Sanitize::Config::BASIC), name: 'About')

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