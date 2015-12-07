require 'uri'

class Thought < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :hashtags
  has_many :comments, -> { order :created_at }, as: :commentable, dependent: :destroy
  has_many :commenters, through: :comments, source: :user, class_name: 'User'
  has_many :likes, class_name: 'Respect', as: :respectable, dependent: :destroy
  has_many :liking_users, class_name: 'User', through: :likes, source: :user
  has_many :notifications, as: :notifiable, dependent: :delete_all
  has_one :link_datum, foreign_key: :link, primary_key: :link

  attr_accessible :raw_body, :link

  before_save :parse_body, if: proc{|t| t.raw_body_changed? }
  before_save :parse_link, if: proc{|t| t.body_changed? }
  before_save :get_link_properties, if: proc{|t| t.link.present? and t.link_changed? }
  after_commit :enqueue_parse_hashtags

  self.per_page = 15

  def self.with_hashtag hashtag
    joins(:hashtags).where("LOWER(hashtags.name) = ?", hashtag.downcase)
  end

  def enqueue_parse_hashtags
    if APP_CONFIG['workers_running']
      delay.parse_hashtags
    else
      parse_hashtags
    end
  end

  def liked_by? user
    likes.where(user_id: user.id).any?
  end

  def has_mentions?
    return unless body

    mentioned_users.any?
  end

  def mentioned_users
    return @mentions if @mentions
    return [] unless body

    user_ids = []
    doc = Nokogiri::HTML::DocumentFragment.parse body
    doc.css('a.mention').each do |mention|
      user_ids << mention['data-user-id']
    end
    @mentions = user_ids.any? ? User.where(id: user_ids) : []
  end

  def reparse_body!
    parse_body
    save if body_changed?
  end

  def parse_hashtags
    return unless raw_body

    raw_body.scan /(?:^|[\s])+#([\w\-]+)(?:\b|\-|\.|,|:|;|\?|!|\(|\)|$)?/ do |match|
      hashtags << Hashtag.where(name: match[0]).first_or_create!
    end
  end

  private
    def get_link_properties
      return unless link.present?

      build_link_datum unless LinkDatum.where(link: link).first
    end

    def parse_body
      return unless raw_body

      markdown = Redcarpet::Markdown.new(Redcarpet::Render::CustomRenderer, Redcarpet::MARKDOWN_FILTERS)
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
