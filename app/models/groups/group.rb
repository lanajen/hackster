class Group < ActiveRecord::Base
  # replicated_model

  ACCESS_LEVELS = {
    'Anyone without approval' => 'anyone',
    'Anyone can request access' => 'request',
    'Only people who are explicitely invited' => 'invite',
  }
  PROJECT_SORTING = {
    'Trending (most popular first)' => 'trending',
    'Most impressions first' => 'popular',
    'Most recent first' => 'recent',
    'Most respects first' => 'respected',
  }
  SORTING = {
    'followers' => :most_members,
    'members' => :most_members,
    'name' => :alphabetical_sorting,
    'projects' => :most_projects,
  }

  include Counter
  include EditableSlug
  include SetChangesForStoredAttributes
  include StringParser

  editable_slug :user_name

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
  has_many :users, through: :members do
    def active
      where("members.requested_to_join_at IS NULL OR members.approved_to_join = 't'")
    end
  end
  has_one :avatar, as: :attachable, dependent: :destroy
  has_one :cover_image, as: :attachable, dependent: :destroy

  attr_accessible :avatar_attributes, :type,
    :facebook_link, :twitter_link, :linked_in_link, :website_link,
    :blog_link, :github_link, :email, :mini_resume, :city, :country,
    :user_name, :full_name, :members_attributes, :avatar_id,
    :permissions_attributes, :google_plus_link, :youtube_link, :access_level,
    :hidden, :slack_token, :slack_hook_url, :cover_image_id, :project_sorting,
    :instagram_link, :flickr_link, :reddit_link, :pinterest_link

  accepts_nested_attributes_for :avatar, :members, :permissions,
    allow_destroy: true

  store :websites, accessors: [:facebook_link, :twitter_link, :linked_in_link,
    :google_plus_link, :youtube_link, :website_link, :blog_link, :github_link,
    :instagram_link, :flickr_link, :reddit_link, :pinterest_link]
  set_changes_for_stored_attributes :websites

  store :properties, accessors: [:hidden, :slack_token,
    :slack_hook_url, :default_project_sorting]
  set_changes_for_stored_attributes :properties

  # :projects_count and :members_count are DB columns! don't include them in counters_cache

  parse_as_booleans :properties, :hidden

  validates :user_name, :new_user_name, length: { in: 3..100 },
    format: { with: /\A[a-zA-Z0-9_\-]+\z/, message: "accepts only letters, numbers, underscores '_' and dashes '-'." }, allow_blank: true, if: proc{|t| t.persisted?}
  validates :user_name, :new_user_name, exclusion: { in: %w(projects terms privacy admin infringement_policy search users communities hackerspaces hackers lists) }
  validates :email, length: { maximum: 255 }
  validate :website_format_is_valid
  before_validation :clean_members
  before_validation :ensure_website_protocol
  after_validation :add_errors_to_user_name
  before_save :ensure_invitation_token

  # beginning of shared search methods
  include TireInitialization
  # end of search methods

  def self.default_access_level
    'anyone'
  end

  def self.default_permission
    'read'
  end

  def self.default_project_sorting
    'trending'
  end

  def self.alphabetical_sorting
    order full_name: :asc
  end

  def self.most_members
    order members_count: :desc
  end

  def self.most_projects
    order projects_count: :desc
  end

  def access_level
    read_attribute(:access_level).presence || self.class.default_access_level
  end

  def avatar_id=(val)
    self.avatar = Avatar.find_by_id(val)
  end

  def counters
    {
      members: 'members.count',
      projects: 'project_collections.visible.count',
    }
  end

  def cover_image_id=(val)
    self.cover_image = CoverImage.find_by_id(val)
  end

  def project_sorting
    default_project_sorting.presence || self.class.default_project_sorting
  end

  def project_sorting=(val)
    self.default_project_sorting = val
  end

  def default_user_name
    name.gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase
  end

  def generate_user_name
    return if full_name.blank?

    slug = default_user_name

    # make sure it doesn't exist
    if result = self.class.where(user_name: slug).first
      unless self == result
        # if it exists add a 1 and increment it if necessary
        slug += '1'
        while self.class.where(user_name: slug).first
          slug.gsub!(/([0-9]+$)/, ($1.to_i + 1).to_s)
        end
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

  def invite_with_emails emails, invited_by=nil, message=nil
    emails.each do |email|
      invite_with_email email, invited_by, message
    end
  end

  def invite_with_email email, invited_by=nil, message=nil
    unless user = User.find_by_email(email)
      user = User.invite!({ email: email }, invited_by) do |u|
        u.skip_invitation = true
      end
    end
    member = members.create user_id: user.id, invitation_sent_at: Time.now, invited_by: invited_by
    user.deliver_invitation_with({ model: member, personal_message: message }) if member.persisted? and user.invited_to_sign_up?
  end

  def has_websites?
    websites.select{|k,v| v.present? }.any?
  end

  def name
    full_name.presence || user_name
  end

  def twitter_handle
    return unless twitter_link.present?

    handle = twitter_link.match(/twitter.com\/(.+)/).try(:[], 1)
    handle.present? ? "@#{handle}" : nil
  end

  private
    def add_errors_to_user_name
      if errors[:new_user_name]
        errors[:new_user_name].each{|e| errors.add :user_name, e }
      end
    end

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
