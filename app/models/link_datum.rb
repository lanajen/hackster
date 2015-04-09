class LinkDatum < ActiveRecord::Base
  TRASH_ELEMENTS = %w(nav header #sidebar #sidebar-right #sidebar-left .sidebar .sidebar-left .sidebar-right #head #header #hd .navbar .navbar-top header footer #ft #footer .sharedaddy .ts-fab-wrapper .shareaholic-canvas .post-nav .navigation .post-data .meta .social-ring .postinfo .page-title)
  has_one :image, as: :attachable, dependent: :destroy

  validate :link_is_not_changed

  before_save :get_link_properties, if: proc{|t| t.link.present? }

  private
    def clean_body body
      body.css(TRASH_ELEMENTS.join(',')).each{|e| e.remove }
      body
    end

    def get_description head, body
      meta(head, 'property="og:description"') || meta(head, 'property="twitter:description"') || meta(head, 'name="description"') || clean_body(body).text.gsub(/\s+/, " ").strip.truncate(200)
    end

    def get_extra_data head, val, num
      meta(head, "property='twitter:#{val}#{num}'")
    end

    def get_link head
      meta(head, 'property="og:link"') || link
    end

    def get_image head, body
      src = meta(head, 'property="og:image"') || meta(head, 'property="twitter:image:src"') || body.at_css('img').try(:[], 'src')
      return unless src

      # stuff taken from scrapers/base.rb
      uri = URI(link)
      @host = uri.host
      @scheme = uri.scheme
      if uri.path.present?
        path = uri.path.split(/\//)[1..-1]
        path.pop if path and path.last =~ /.+\..+/
        @base_uri = "#{path.join('/')}" if path
      end
      @base_uri = @base_uri.present? ? "/#{@base_uri}" : ''
      normalize_link src
    end

    def get_link_properties
      return unless link.present?

      if content = fetch_page(link)
        doc = Nokogiri::HTML(content)
        head = doc.at_css('head')
        body = doc.at_css('body')
        self.title = get_title head
        self.website_name = get_website_name head
        self.link = get_link head
        captured_image = get_image head, body
        if captured_image.present?
          build_image unless image
          image.remote_file_url = captured_image
        end
        self.description = get_description head, body
        self.extra_data_value1 = get_extra_data head, 'data', 1
        self.extra_data_label1 = get_extra_data head, 'label', 1
        self.extra_data_value2 = get_extra_data head, 'data', 2
        self.extra_data_label2 = get_extra_data head, 'label', 2
      end
    end

    def get_title head
      meta(head, 'property="og:title"') || meta(head, 'property="twitter:title"') || head.at_css('title').try(:text).try(:strip)
    end

    def get_website_name head
      meta(head, 'property="og:site_name"') || URI(link).host
    end

    def meta head, name
      head.at_css("meta[#{name}]").try(:[], :content).try(:strip)
    end

    def fetch_page page_url
      page_url = 'http://' + page_url unless page_url =~ /^https?\:\/\//
      puts "Fetching page #{page_url}..."
      5.times do
        begin
          return open(page_url, allow_redirections: :safe, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
        rescue => e
          # raise e.inspect
          puts "Failed opening #{page_url}. Retrying in 1 second..."
          sleep 1
        end
      end
      # raise "Failed opening page #{page_url} after 5 tries."
      nil
    end

    def link_is_not_changed
      errors.add :link, "Change of link not allowed!" if link_changed? and self.persisted?
    end

    def normalize_link src
      return src if src =~ /\Amailto/

      src = "#{@scheme}:" + src if (src =~ /\A\/\//)
      if (src !~ /\Ahttp/) and @host and src != '/'
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
end
