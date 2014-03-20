class Group < ActiveRecord::Base
  ACCESS_LEVELS = {
    'Anyone without approval' => 'anyone',
    'Anyone can request access' => 'request',
    'Only people who are explicitely invited' => 'invite',
  }

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
    :permissions_attributes, :google_plus_link, :youtube_link, :new_user_name,
    :access_levels
  attr_writer :new_user_name

  accepts_nested_attributes_for :avatar, :members, :permissions,
    allow_destroy: true

  store :websites, accessors: [:facebook_link, :twitter_link, :linked_in_link,
    :google_plus_link, :youtube_link, :website_link, :blog_link, :github_link]
  validates :user_name, :new_user_name, exclusion: { in: %w(projects terms privacy admin infringement_policy search users) }
  validates :user_name, :new_user_name, length: { in: 3..100 }, if: proc{|t| t.persisted?}
  validate :website_format_is_valid
  before_validation :assign_new_user_name
  before_validation :clean_members
  before_validation :ensure_website_protocol

  def self.default_access_level
    'anyone'
  end

  def self.default_permission
    'read'
  end

  def access_level
    read_attribute(:access_level).presence || self.class.default_access_level
  end

  def assign_new_user_name
    @old_user_name = user_name
    self.user_name = new_user_name
  end

  def avatar_id=(val)
    self.avatar = Avatar.find_by_id(val)
  end

  def generate_user_name exclude_destroyed=true
    # raise members.reject{|m| m.marked_for_destruction? }.to_s
    cached_members = members
    cached_members = cached_members.reject{|m| m.marked_for_destruction? } if exclude_destroyed
    self.user_name = cached_members.map{|m| m.user.user_name }.to_sentence.gsub(/,/, '').gsub(/[ ]/, '_')
    # cached_members = members.to_a
    # self.user_name = if cached_members.size > 1
    #   cached_members.map{|m| m.user.user_name[0..1] }.join('')
    # elsif cached_members.size == 0
    #   ''
    # else
    #   cached_members.first.user.user_name
    # end
  end

  # def generate_user_name exclude_destroyed=true
  #   # raise members.reject{|m| m.marked_for_destruction? }.to_s
  #   cached_members = members
  #   cached_members = cached_members.reject{|m| m.marked_for_destruction? } if exclude_destroyed
  #   # if cached_members.size == 1
  #   #   self.user_name = cached_members.first.user.user_name
  #   # end
  #   cached_members = members.to_a
  #   self.user_name = if cached_members.size > 1
  #     id
  #   elsif cached_members.size == 0
  #     ''
  #   else
  #     cached_members.first.user.user_name
  #   end
  # end

  def identifier
    self.class.name.to_s.underscore
  end

  def is? group_type
    self.class.name.underscore == group_type.to_s
  end

  def name
    full_name || user_name
  end

  def new_user_name
    # raise new_user_name.to_s
    @new_user_name ||= user_name
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

    def ensure_invitation_token
      self.invitation_token = SecureRandom.urlsafe_base64(nil, false) if invitation_token.nil?
    end

    def website_format_is_valid
      websites.each do |type, url|
        next if url.blank?
        errors.add type.to_sym, 'is not a valid URL' unless url.downcase =~ URL_REGEXP
      end
    end
end
