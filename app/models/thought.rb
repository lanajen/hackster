require 'uri'

class Thought < ActiveRecord::Base
  belongs_to :user
  has_many :comments, -> { order :created_at }, as: :commentable, dependent: :destroy
  has_many :likes, class_name: 'Respect', as: :respectable, dependent: :destroy
  has_many :liking_users, class_name: 'User', through: :likes, source: :user
  has_one :link_datum, foreign_key: :link, primary_key: :link

  attr_accessible :raw_body, :link

  before_save :parse_body
  before_save :parse_link
  before_save :get_link_properties, if: proc{|t| t.link.present? }

  def liked_by? user
    likes.where(user_id: user.id).any?
  end

  private
    def get_link_properties
      return unless link.present?

      build_link_datum unless LinkDatum.where(link: link).first
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
