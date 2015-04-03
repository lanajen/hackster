require 'uri'

class Thought < ActiveRecord::Base
  belongs_to :user
  has_many :comments, -> { order :created_at }, as: :commentable, dependent: :destroy
  has_many :likes, class_name: 'Respect', as: :respectable, dependent: :destroy
  has_many :liking_users, class_name: 'User', through: :likes, source: :user

  attr_accessible :raw_body, :link

  store :cached_link_properties, accessors: [:title, :image_link, :website_name,
    :description, :extra_data_value1, :extra_data_label1, :extra_data_value2,
    :extra_data_label2]

  before_save :parse_body
  before_save :parse_link
  before_save :get_link_properties, if: proc{|t| t.link.present? }

  def liked_by? user
    likes.where(user_id: user.id).any?
  end

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
        self.image_link = get_image head
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

    def parse_body
      return unless raw_body

      filters = {
        autolink: true,
        no_styles: true,
        no_images: true,
        escape_html: true,
      }

      markdown = Redcarpet::Markdown.new(Redcarpet::Render::TargetBlankHTML, filters)
      self.body = markdown.render(raw_body)
    end

    def parse_link
      # self.link = URI.extract(body, %w(http https)).first
      doc = Nokogiri::HTML::DocumentFragment.parse body
      doc.css('a').each do |a|
        if a['href'] and URI.parse(a['href']).scheme.in? %w(http https)
          self.link = a['href']
          break
        end
      end
    end
end
