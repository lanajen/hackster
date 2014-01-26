module ScraperStrategies
  class Base
    LINK_REGEXP = {
      /123d\.circuits\.io/ => 'CircuitsioWidget.new(link:"|href|",name:"Schematics on Circuits.io")',
      /github\.com\/[0-9a-zA-Z_\-]+\/[0-9a-zA-Z_\-]+\z/ => 'GithubWidget.new(repo:"|href|",name:"Github repo")',
      /oshpark\.com\/shared_projects/ => 'OshparkWidget.new(link:"|href|",name:"PCB on OSH Park")',
      /tindie\.com/ => 'BuyWidget.new(link:"|href|",name:"Where to buy")',
      /upverter\.com/ => 'UpverterWidget.new(link:"|href|",name:"Schematics on Upverter")',
      /vimeo\.com/ => 'VideoWidget.new(video_attributes:{link:"|href|"},name:"Demo video")',
      /youtube\.com/ => 'VideoWidget.new(video_attributes:{link:"|href|"},name:"Demo video")',
      /youtu\.be/ => 'VideoWidget.new(video_attributes:{link:"|href|"},name:"Demo video")',
    }

    def initialize parsed, page_url=''
      @parsed = parsed
      uri = URI(page_url)
      @host = uri.host
      if uri.path.present?
        path = uri.path.split(/\//)[1..-1]
        path.pop if path.last =~ /.+\..+/
        @base_uri = "#{path.join('/')}"
      end
      @base_uri = @base_uri.present? ? "/#{@base_uri}" : ''
    end

    def to_project
      puts 'Converting to project...'

      @project = Project.new private: true
      @widgets = []

      @article = @parsed

      @project.name = @article.at_css('.entry-title').try(:remove).try(:text) || @article.css('h1').last.try(:remove).try(:text) || @parsed.title

      yield if block_given?

      parse_links
      parse_images

      raw_text = @article.css('p').map{|p| p.to_html }.join('')
      sanitized_text = Sanitize.clean(raw_text.try(:encode, "UTF-8"), Sanitize::Config::BASIC)
      text = Nokogiri::HTML(sanitized_text)
      text.css('a').find_all.each{|el| el.remove if el.content.strip.blank? }
      text.css('p').find_all.each{|el| el.remove if el.content.strip.blank? }
      text = Sanitize.clean(text.to_html, Sanitize::Config::BASIC_BLANK)
      @widgets << TextWidget.new(content: text, name: 'About')

      distribute_widgets

      @project
    end

    private
      def distribute_widgets
        widget_col = 1
        widget_row = 1
        count = 0
        @widgets.each do |widget|
          @project.widgets << widget
          widget.position = "#{widget_col}.#{widget_row}"
          if count.even?
            widget_col += 1
          else
            widget_row += 1
          end
          count += 1
        end
      end

      def normalize_image_link src
        if !(src =~ /\Ahttp/) and @host
          src = "#{@base_uri}/#{src}" unless src =~ /\A\//
          clean_path = []
          src.split('/')[1..-1].each do |dir|
            if dir == '..'
              clean_path.pop
            elsif !(dir == '.')
              clean_path << dir
            end
          end
          src = "http://#{@host}/#{clean_path.join('/')}"
        end
        src
      end

      def parse_images
        image_widget = ImageWidget.new name: 'Photos'
        @article.css('img').each_with_index do |img, i|
          src = normalize_image_link(img['src'])
          puts "Parsing image #{src}"
          image_widget.images.new(remote_file_url: src, title: img['title'], position: i)
        end
        @widgets << image_widget if image_widget.images.any?

        if img = @article.at_css('img')
          src = normalize_image_link(img['src'])
          puts "Parsing image #{src}"
          @project.build_cover_image remote_file_url: src
        end
      end

      def parse_links
        {
          'a' => 'href',
          'iframe' => 'src',
        }.each do |el, attr|
          collection = []
          @article.css(el).each do |link|
            collection << link[attr]
          end
          collection.uniq.each do |link|
            LINK_REGEXP.each do |regexp, command|
              if link =~ Regexp.new(regexp)
                command = command.gsub(/\|href\|/, link)
                widget = eval command
                @widgets << widget
                break
              end
            end
          end
        end
    end
  end
end