module ScraperStrategies
  class Base
    LINK_REGEXP = {
      /123d\.circuits\.io/ => 'CircuitsioWidget.new(link:"|href|",name:"Schematics on Circuits.io")',
      /bitbucket\.org/ => 'BitbucketWidget.new(repo:"|href|",name:"Bitbucket repo")',
      /github\.com/ => 'GithubWidget.new(repo:"|href|",name:"Github repo")',
      /instagram\.com/ => 'VideoWidget.new(video_attributes:{link:"|href|"},name:"Demo video")',
      /oshpark\.com\/shared_projects/ => 'OshparkWidget.new(link:"|href|",name:"PCB on OSH Park")',
      /tindie\.com/ => 'BuyWidget.new(link:"|href|",name:"Where to buy")',
      /upverter\.com/ => 'UpverterWidget.new(link:"|href|",name:"Schematics on Upverter")',
      /ustream\.tv\/([a-z]+\/[0-9]+)/ => 'VideoWidget.new(video_attributes:{link:"|href|"},name:"Demo video")',
      /vimeo\.com/ => 'VideoWidget.new(video_attributes:{link:"|href|"},name:"Demo video")',
      /vine\.co/ => 'VideoWidget.new(video_attributes:{link:"|href|"},name:"Demo video")',
      /youtu(\.be|be\.com)/ => 'VideoWidget.new(video_attributes:{link:"|href|"},name:"Demo video")',
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

      @project.name = @article.at_css('.entry-title').try(:remove).try(:text) || @parsed.title

      yield if block_given?

      parse_links
      parse_images
      parse_text

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

      def get_src_for_img img
        src = img['src']

        # if rel attr links to a bigger image get that one
        if rel = img['rel']
          return rel if rel =~ /\.(png|jpg|jpeg)$/
        end

        # if parent is a link to a bigger image get that link instead
        parent = img.parent
        if parent.name == 'a'
          href = parent['href']
          return href if href =~ /\.(png|jpg|jpeg)$/
        end

        src
      end

      def normalize_image_link src
        src = 'http:' + src if (src =~ /\A\/\//)
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
        collection = {}
        @article.css('img').each do |img|
          src = normalize_image_link get_src_for_img(img)
          collection[src] = img['title']
        end

        i = 0
        collection.each do |src, title|
          puts "Parsing image #{src}"
          image_widget.images.new(remote_file_url: src, title: title.try(:truncate, 255), position: i)
          i += 1
        end
        @widgets << image_widget if image_widget.images.any?

        if img = collection.first
          @project.build_cover_image remote_file_url: img[0]
        end
      end

      def parse_links
        {
          'a' => 'href',
          'embed' => 'src',
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

    def parse_text
      # find the first level title tag (h), replaces by h5, and replaces further
      # levels by h6
      (2..4).each do |i|
        if @article.css("h#{i}").any?
          @article.css("h#{i}").each { |h| h.name = 'h5' }
          (i+1..4).each do |j|
            @article.css("h#{j}").each { |h| h.name = 'h6' }
          end if i < 4
          break
        end
      end
      raw_text = @article.to_html
      sanitized_text = Sanitize.clean(raw_text.try(:encode, "UTF-8"), Sanitize::Config::BASIC_BLANK)
      text = Nokogiri::HTML::DocumentFragment.parse(sanitized_text)
      text.css('a, p, h5, h6').find_all.each{|el| el.remove if el.content.strip.blank? }

      # finds all main titles (h5), split and create a widget with the content
      text.to_html.gsub(/\r?\n/, ' ').split(/<h5>/).each_with_index do |frag, i|
        frag = '<h5>' + frag if i > 0
        frag.match /<h5>([^<]+)<\/h5>/
        if title = $1
          frag.gsub! "<h5>#{title}</h5>", ''
        end
        frag.gsub! /(^(<br\/?>)+)?((<br\/?>)+$)?/, ''
        @widgets << TextWidget.new(content: frag, name: title.try(:truncate, 100) || 'About')
      end
    end
  end
end