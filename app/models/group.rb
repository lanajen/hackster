class Group < ActiveRecord::Base
  has_many :broadcasts, through: :users
  has_many :issues, through: :projects
  has_many :members, dependent: :destroy
  has_many :projects, through: :users
  has_many :users, through: :members
  has_one :avatar, as: :attachable, dependent: :destroy

  attr_accessible :avatar_attributes,
    :facebook_link, :twitter_link, :linked_in_link, :website_link,
    :blog_link, :github_link, :email, :mini_resume, :city, :country,
    :user_name, :full_name

  accepts_nested_attributes_for :avatar, allow_destroy: true

  store :websites, accessors: [:facebook_link, :twitter_link, :linked_in_link, :website_link, :blog_link, :github_link]
  before_validation :ensure_website_protocol

  def name
    full_name
  end

  private
    def ensure_website_protocol
      return unless websites_changed?
      websites.each do |type, url|
        if url.blank?
          send "#{type}=", nil
          next
        end
        send "#{type}=", 'http://' + url unless url =~ /^http/
      end
    end
end
