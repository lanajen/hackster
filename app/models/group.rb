class Group < ActiveRecord::Base
  has_many :broadcasts, through: :users
  has_many :granted_permissions, as: :grantee, class_name: 'Permission'
  has_many :issues, through: :projects
  has_many :members, dependent: :destroy
  has_many :permissions, as: :permissible
  has_many :users, through: :members
  has_one :avatar, as: :attachable, dependent: :destroy

  attr_accessible :avatar_attributes,
    :facebook_link, :twitter_link, :linked_in_link, :website_link,
    :blog_link, :github_link, :email, :mini_resume, :city, :country,
    :user_name, :full_name, :members_attributes, :avatar_id,
    :permissions_attributes, :google_plus_link, :youtube_link

  accepts_nested_attributes_for :avatar, :members, :permissions,
    allow_destroy: true

  store :websites, accessors: [:facebook_link, :twitter_link, :linked_in_link,
    :google_plus_link, :youtube_link, :website_link, :blog_link, :github_link]
  validates :user_name, exclusion: { in: %w(projects terms privacy admin infringement_policy search users) }
  before_validation :clean_members
  before_validation :ensure_website_protocol

  def self.default_permission
    'read'
  end

  def avatar_id=(val)
    self.avatar = Avatar.find_by_id(val)
  end

  def generate_user_name
    self.user_name = members.map{|m| m.user.user_name }.to_sentence.gsub(/[ ,]/, '_')
  end

  def is? group_type
    self.class.name.underscore == group_type.to_s
  end

  def name
    full_name || user_name
  end

  private
    def clean_members
      members.each do |member|
        members.delete(member) if member.new_record? and member.user.nil?
      end
    end

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
