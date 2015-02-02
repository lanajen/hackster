module ScraperStrategies
  class Base
    include ScraperUtils

    def initialize parsed, page_url=''
      @page_url = page_url
      @parsed = parsed
      uri = URI(page_url)
      @scheme = uri.scheme || 'http'
      @host = uri.host
      if uri.path.present?
        path = uri.path.split(/\//)[1..-1]
        path.pop if path and path.last =~ /.+\..+/
        @base_uri = "#{path.join('/')}" if path
      end
      @base_uri = @base_uri.present? ? "/#{@base_uri}" : ''
    end

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
      parse_comments
      format_text
      parse_cover_image
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
      def after_parse
        @widgets.each{|w| @project.widgets << w }
      end

      def before_parse
        @article.css(crap_list.join(',')).each{|n| n.remove }
      end

      def clean_divs parent
        traverse parent do |node|
          if node.name == 'div' and node['class'] != 'embed-frame'
            node.after '<br>'
            node.replace node.children
          end
        end
      end

      def clean_up_formatting base_name='@article'
        base = instance_variable_get base_name
        # @article.search('//text()').each{|el| el.remove if el.content.strip.blank? }
        base.css('a, p, h3, h4, pre').each{|el| el.remove if el.content.strip.blank? }

        sanitized_text = Sanitize.clean(base.to_s.try(:encode, "UTF-8"), Sanitize::Config::SCRAPER)
        instance_variable_set base_name, Nokogiri::HTML::DocumentFragment.parse(sanitized_text)

        clean_divs instance_variable_get(base_name)
      end

      def crap_list
        %w(#sidebar #sidebar-right #sidebar-left .sidebar .sidebar-left .sidebar-right #head #header #hd .navbar .navbar-top header footer #ft #footer .sharedaddy .ts-fab-wrapper .shareaholic-canvas .post-nav .navigation .post-data .meta .social-ring .postinfo)
      end

      def extract_code_blocks base=@article
        base.css('pre code, .crayon-syntax .crayon-main, .syntaxhighlighter .code, pre')
      end

      def extract_code_lines node
        if node.name.in? %w(code pre)
          code = node.content.gsub(/<br ?\/?>/, "\r\n")
          code.lines.count <= 5 ? nil : code  # we leave snippets in place
        else
          node.css('.crayon-line, .line').map{|l| l.content }.join("\r\n")
        end
      end

      def extract_comments
        @parsed.at_css('#comments')
      end

      def extract_cover_image
        @article.css('img').each do |img|
          src = get_src_for_img(img)
          return img if test_link src
        end
        nil
      end

      def extract_images base=@article, super_base=nil
        base.css('img').each do |img|
          src = get_src_for_img(img, base)
          if test_link(src)
            ext = File.extname(URI.parse(src).path)[1..-1]
            # img.remove and next unless ext.in? ImageUploader::EXTENSION_WHITE_LIST
            img['src'] = src
            caption = find_caption_for img, base
            img['title'] = caption if caption.present?
            parent = find_parent img, base
            parent.after img unless parent == img
          else
            img.remove
          end
        end
      end

      def extract_title
        @article.at_css('.entry-title').try(:remove).try(:text).try(:strip) || @parsed.title
      end

      def find_caption_for img, base_parent=@article
        if img.parent and img.parent != base_parent
          if img.parent.name == 'figure' or (img.parent['class'] and (img.parent['class'].split(' ') & image_caption_container_classes).any?)
            node = img.parent.css(image_caption_elements.join(','))
            text = node.text
            node.remove
            text
          else
            find_caption_for img.parent, base_parent
          end
        end
      end

      def image_caption_container_classes
        %w()
      end

      def image_caption_elements
        %w(figcaption)
      end

      def find_parent node, base_parent=@article, additional_tags=%w()
        if node.parent and node.parent != base_parent
          # find_parent node.parent
          node.parent.name.in?(%w(a span) + additional_tags) ? find_parent(node.parent, base_parent) : node.parent
        else
          node
        end
        # node.parent and node.parent != @article ? node.parent : node
      end

      def format_text base=@article
        base.css('strong').each do |node|
          node.name = 'b'
        end
        base.css('em').each do |node|
          node.name = 'i'
        end

        # find the first level title tag (h), replaces by h3, and replaces next
        # level by h4, and further levels by b
        h = {}
        (title_levels).each do |i|
          h[i] = base.css("h#{i}")
        end
        (title_levels).each do |i|
          if h[i].any?
            h[i].each { |h| h.name = 'h3' }
            (i+1..4).each do |j|
              if h[j].any?
                h[j].each { |h| h.name = 'h4' }
                (j+1..3).each do |l|
                  h[l].each { |h| h.name = 'b' }
                end
                break
              end
            end if i < 4
            break
          end
        end
      end

      def get_src_for_img img, base_parent=@article
        src = img['src']

        # if rel attr links to a bigger image get that one
        if rel = img['rel']
          return rel if rel =~ /\.(png|jpg|jpeg|bmp|gif)$/
        end

        if img.name == 'a'
          img.name = 'span'  # so that it's not parsed as an embed later on
          return img['href']
        end

        # if parent is a link to a bigger image get that link instead
        parent = img
        while parent.respond_to?(:parent) and parent = parent.parent and parent != base_parent do
          if parent.name == 'a'
            href = parent['data-fancybox-href'] || parent['href']
            parent.name = 'span'  # so that it's not parsed as an embed later on
            src = href if href =~ /\.(png|jpg|jpeg|bmp|gif)$/
            break
          end
        end

        src
      end

      def normalize_links base=@article
        {
          'a' => 'href',
          'img' => 'src',
        }.each do |name, attr|
          base.css(name).each do |node|
            node[attr] = normalize_link(node[attr]) if node[attr]
          end
        end
      end

      def normalize_link src
        src = "#{@scheme}:" + src if (src =~ /\A\/\//)
        if !(src =~ /\Ahttp/) and @host and src != '/'
          src = "#{@base_uri}/#{src}" unless src =~ /\A\//
          clean_path = []
          src.split('/')[1..-1].each do |dir|
            if dir == '..'
              clean_path.pop
            elsif !(dir == '.')
              clean_path << dir
            end
          end
          src = "#{@scheme}://#{@host}/#{clean_path.join('/')}"
        end
        src.gsub /\s/, '%20'
      end

      def parse_cover_image
        if img = extract_cover_image
          src = get_src_for_img(img)
          image = @project.build_cover_image
          image.skip_file_check!
          image.remote_file_url = src
        end
      end

      def parse_code base=@article
        extract_code_blocks(base).each do |node|
          next unless code = extract_code_lines(node)

          widget = CodeWidget.new(raw_code: code, name: 'Code')
          widget.widgetable_id = 0
          widget.save
          parent = find_parent node, base
          parent.after "<div class='embed-frame' data-widget-id='#{widget.id}' data-type='widget'></div>"
          @widgets << widget
          node.remove  # remove so it's not added to text later
        end
      end

      def parse_embeds base=@article
        {
          # 'a' => 'href',
          'embed' => 'src',
          'iframe' => 'src',
          'object' => 'data',
        }.each do |el, attr|
          base.css(el).each do |node|
            embed = Embed.new url: node[attr]
            if embed.provider
              @embedded_urls[embed.provider_name] << embed.provider_id
              parent = find_parent node, base, %w(li ol ul)
              parent.after "<div class='embed-frame' data-url='#{embed.url}' data-type='url'></div>"
            end
            node.remove
          end
        end

        collection = []
        base.css('a').each do |node|
          collection << node
        end
        collection.uniq.each do |node|
          embed = Embed.new url: node['href']
          if embed.provider
            unless embed.provider_id.in? @embedded_urls[embed.provider_name]
              @embedded_urls[embed.provider_name] << embed.provider_id
              parent = find_parent node, base, %w(li ol ul)
              parent.after "<div class='embed-frame' data-url='#{embed.url}' data-type='url'></div>"
            end
          end
        end
      end

      def parse_comments
        extract_comments.remove if extract_comments
      end

      def parse_files base=@article, attachable=@project
        files = {}
        base.css('a').each do |node|
          next unless link = node['href']
          if link.match /\/\/.+\/.+\.([a-z0-9]{,5})$/
            next if $1.in? %w(html htm gif jpg jpeg png bmp php aspx asp js css)
            next unless test_link(link)
            content = node.text
            title = (content != link) ? content : ''
            puts "Parsing file #{link}..."
            document = Document.new remote_file_url: link, title: title.truncate(255)
            document.attachable_id = 0
            document.attachable_type = 'Orphan'
            document.save
            document.attachable = attachable
            parent = find_parent node, base, %w(li ol ul)
            parent.after "<div class='embed-frame' data-file-id='#{document.id}' data-type='file'></div>"
          end
        end
      end

      def parse_images base=@article, super_base=nil
        # extract_images.each do |img|
        #   src = get_src_for_img(img)
        #   if test_link(src)
        #     img['src'] = src
        #     caption = find_caption_for img
        #     img['title'] = caption if caption.present?
        #     parent = find_parent img
        #     parent.after img unless parent == img
        #   else
        #     img.remove
        #   end
        # end

        if super_base.nil?
          extract_images base
        else
          extract_images base, super_base
        end

        imgs = base.css('img')
        length = imgs.size
        i = 0
        while (i < length) do
          node = imgs[i]
          if node.name == 'img'
            this_images = [node]
            next_node = node
            while (next_node = next_node.next and (next_node.content.strip.blank? or next_node.name == 'img')) do
              if next_node.name == 'img'
                n = imgs[i+1]
                this_images << n
                i = i + 1
              end
            end

            widget = ImageWidget.new
            widget.widgetable_id = 0
            this_images.each_with_index do |img, x|
              src = img['src']
              puts "Parsing image #{src}..."
              image = widget.images.new title: img['title'], position: x
              image.skip_file_check!
              image.remote_file_url = src
            end
            widget.save
            @widgets << widget
            node.after "<div class='embed-frame' data-widget-id='#{widget.id}' data-type='widget'></div>"
          end
          i = i + 1
        end

        imgs.each{|n| n.remove }
      end

      def select_article
        @parsed.at('#content') || @parsed.at('#main') || @parsed.at('body')
      end

      def title_levels
        2..4
      end

      def traverse(node, &block)
        block.call(node)

        child = node.child

        while child do
          prev = child.previous_sibling
          traverse(child, &block)

          if child.parent != node
            # The child was unlinked or reparented, so traverse the previous node's
            # next sibling, or the parent's first child if there is no previous
            # node.
            child = prev ? prev.next_sibling : node.child
          else
            child = child.next_sibling
          end
        end
      end

      def unwrap node
        node.children.each do |child|
          node.parent << child
        end
        node.remove
      end
  end
end