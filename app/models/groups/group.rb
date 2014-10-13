class Group < ActiveRecord::Base
  ACCESS_LEVELS = {
    'Anyone without approval' => 'anyone',
    'Anyone can request access' => 'request',
    'Only people who are explicitely invited' => 'invite',
  }

  include SetChangesForStoredAttributes

  is_impressionable counter_cache: true, unique: :session_hash

  has_many :active_members, -> { where("members.requested_to_join_at IS NULL OR members.approved_to_join = 't'") }, foreign_key: :group_id, class_name: 'Member'
  has_many :broadcasts, through: :users
  has_many :featured_projects, -> { where("project_collections.workflow_state = 'featured'") }, source: :project, through: :project_collections
  has_many :granted_permissions, as: :grantee, class_name: 'Permission'
  has_many :members, dependent: :destroy
  has_many :permissions, as: :permissible
  has_many :project_collections, dependent: :destroy, as: :collectable
  has_many :projects, through: :project_collections do
    # TOOD: see if this can be delegated to ProjectCollection
    def visible
      where(project_collections: { workflow_state: ProjectCollection::VALID_STATES })
    end
  end
  has_many :users, through: :members
  has_one :avatar, as: :attachable, dependent: :destroy

  attr_accessible :avatar_attributes, :type,
    :facebook_link, :twitter_link, :linked_in_link, :website_link,
    :blog_link, :github_link, :email, :mini_resume, :city, :country,
    :user_name, :full_name, :members_attributes, :avatar_id,
    :permissions_attributes, :google_plus_link, :youtube_link, :new_user_name,
    :access_level
  attr_writer :new_user_name

  accepts_nested_attributes_for :avatar, :members, :permissions,
    allow_destroy: true

  store :websites, accessors: [:facebook_link, :twitter_link, :linked_in_link,
    :google_plus_link, :youtube_link, :website_link, :blog_link, :github_link]
  set_changes_for_stored_attributes :websites

  validates :user_name, :new_user_name, exclusion: { in: %w(projects terms privacy admin infringement_policy search users) }
  validates :email, length: { maximum: 255 }
  validate :website_format_is_valid
  before_validation :assign_new_user_name
  before_validation :clean_members
  before_validation :ensure_website_protocol
  before_save :ensure_invitation_token

  # beginning of shared search methods
  include TireInitialization
  has_tire_index 'private'
  # end of search methods

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

  def generate_user_name
    return if full_name.blank?

    slug = name.gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase

    # make sure it doesn't exist
    if result = self.class.where(user_name: slug).first
      return if self == result
      # if it exists add a 1 and increment it if necessary
      slug += '1'
      while self.class.where(user_name: slug).first
        slug.gsub!(/([0-9]+$)/, ($1.to_i + 1).to_s)
      end
    end
    self.user_name = slug
  end

  def identifier
    self.class.name.to_s.underscore
  end

  def is? group_type
    self.class.name.underscore == group_type.to_s
  end

  def invite_with_emails emails, invited_by=nil
    emails.each do |email|
      invite_with_email email, invited_by
    end
  end

  def invite_with_email email, invited_by=nil
    unless user = User.find_by_email(email)
      user = User.invite!({ email: email }, invited_by) do |u|
        u.skip_invitation = true
      end
    end
    member = members.create user_id: user.id, invitation_sent_at: Time.now, invited_by: invited_by
    user.deliver_invitation_with member if member.persisted? and user.invited_to_sign_up?
  end

  def name
    full_name.presence || user_name
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
        next if type.in? skip_website_check
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

    def skip_website_check
      []
    end

    def website_format_is_valid
      websites.each do |type, url|
        next if url.blank? or type.in? skip_website_check
        errors.add type.to_sym, 'is not a valid URL' unless url.downcase =~ URL_REGEXP
      end
    end
end
