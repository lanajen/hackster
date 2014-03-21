module ScraperStrategies
  class Base
    include ScraperUtils

    LINK_REGEXP = {
      /123d\.circuits\.io\/circuits\/([a-z0-9\-]+)/ => 'CircuitsioWidget.new(link:"|href|",name:"Schematics on Circuits.io")',
      /bitbucket\.org\/([0-9a-zA-Z_\-]+\/[0-9a-zA-Z_\-]+)/ => 'BitbucketWidget.new(repo:"|href|",name:"Bitbucket repo")',
      /github\.com\/([0-9a-zA-Z_\-]+\/[0-9a-zA-Z_\-]+)/ => 'GithubWidget.new(repo:"|href|",name:"Github repo")',
      /instagram\.com/ => 'VideoWidget.new(video_attributes:{link:"|href|"},name:"Demo video")',
      /oshpark\.com\/shared_projects/ => 'OshparkWidget.new(link:"|href|",name:"PCB on OSH Park")',
      /sketchfab\.com\/models\/([a-z0-9]+)/ => 'SketchfabWidget.new(link:"|href|",name:"Renderings on Sketchfab")'
      /tindie\.com/ => 'BuyWidget.new(link:"|href|",name:"Where to buy")',
      /upverter\.com\/[^\/]+\/([a-z0-9]+)\/([^\/]+)/ => 'UpverterWidget.new(link:"|href|",name:"Schematics on Upverter")',
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

      @article = select_article
      @project.name = extract_title

      before_parse

      parse_links
      parse_images
      parse_files
      parse_code
      parse_text

      after_parse

      distribute_widgets

      @project
    end

    private
      def after_parse
      end

      def before_parse
      end

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

      def extract_title
        @article.at_css('.entry-title').try(:remove).try(:text) || @parsed.title
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

      def parse_code
        @article.css('pre, code, .code').each do |el|
          # if the node has children with code we skip it
          catch :haschildren do
            el.children.each{ |child| throw :haschildren if child.name.in? %w(pre code) }
            code = el.inner_html.gsub(/<br ?\/?>/, "\r\n")
            next if code.lines.count <= 5  # we leave snippets in place

            @widgets << CodeWidget.new(raw_code: code, name: 'Code')
            el.remove  # remove so it's not added to text later
          end
        end
      end

      def parse_files
        files = {}
        @article.css('a').each do |el|
          next unless link = el['href']
          if link.match /\/\/.+\/.+\.([a-z0-9]{,5})$/
            next if $1.in? %w(html htm gif jpg jpeg png php aspx asp js css)
            next unless test_link(link)
            files[link] = el.text
          end
        end

        return if files.empty?

        document_widget = DocumentWidget.new name: 'Files'

        files.each do |link, content|
          title = (content != link) ? content : ''
          puts "Parsing file #{link}..."
          document_widget.documents.new remote_file_url: link, title: title.truncate(255)
        end
        @widgets << document_widget
      end

      def parse_images
        image_widget = ImageWidget.new name: 'Photos'
        collection = {}
        @article.css('img').each do |img|
          src = normalize_image_link get_src_for_img(img)
          next unless test_link(src)
          collection[src] = img['title']
        end

        i = 0
        collection.each do |src, title|
          puts "Parsing image #{src}..."
          image = image_widget.images.new(remote_file_url: src, title: title.try(:truncate, 255), position: i)
          image.skip_file_check!
          i += 1
        end
        @widgets << image_widget if image_widget.images.any?

        if img = collection.first
          image = @project.build_cover_image remote_file_url: img[0]
          image.skip_file_check!
        end
      end

      def parse_links
        {
          'a' => 'href',
          'embed' => 'src',
          'iframe' => 'src',
          'object' => 'data',
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

    def title_levels
      2..4
    end

    def parse_text
      # find the first level title tag (h), replaces by h5, and replaces further
      # levels by h6
      (title_levels).each do |i|
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
      text.css('a, p, h5, h6').each{|el| el.remove if el.content.strip.blank? }

      # finds all main titles (h5), split and create a widget with the content
      text.to_html.gsub(/\r?\n/, ' ').split(/<h5>/).each_with_index do |frag, i|
        frag = '<h5>' + frag if i > 0
        frag.match /<h5>(.+)<\/h5>/
        if title = $1
          frag.gsub! "<h5>#{title}</h5>", ''
          title = ActionView::Base.full_sanitizer.sanitize title
        end
        frag.gsub! /(^(<br ?\/?>)+)?((<br ?\/?>)+$)?/, ''
        @widgets << TextWidget.new(content: frag, name: title.try(:truncate, 100) || 'About')
      end
    end

    def select_article
      @parsed
    end
  end
end