class LinkDatum < ActiveRecord::Base
  has_one :image, as: :attachable, dependent: :destroy

  validate :link_is_not_changed

  before_save :get_link_properties, if: proc{|t| t.link.present? }

  private
    def get_description head
      meta(head, 'property="og:description"') || meta(head, 'property="twitter:description"') || meta(head, 'name="description"')
    end

    def get_extra_data head, val, num
      meta(head, "property='twitter:#{val}#{num}'")
    end

    def get_link head
      meta(head, 'property="og:link"') || link
    end

    def get_image head
      meta(head, 'property="og:image"') || meta(head, 'property="twitter:image:src"')
    end

    def get_link_properties
      return unless link.present?

      if content = fetch_page(link)
        doc = Nokogiri::HTML(content)
        head = doc.at_css('head')
        self.title = get_title head
        self.description = get_description head
        self.website_name = get_website_name head
        self.link = get_link head
        build_image unless image
        image.remote_file_url = get_image head
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
end
