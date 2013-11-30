class User < ActiveRecord::Base
  include Counter
  include StringParser
  include Taggable

  ROLES = %w(admin confirmed_user)

  CATEGORIES = [
    'Electrical engineer',
    'Industrial designer',
    'Investor',
    'Manufacturer',
    'Mechanical engineer',
    'Software developer',
  ]

  devise :database_authenticatable, :registerable, :invitable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, omniauth_providers: [:facebook, :github, :gplus, :linkedin, :twitter]

  belongs_to :invite_code
  with_options class_name: 'User', join_table: :follow_relations do |u|
    u.has_and_belongs_to_many :followers, foreign_key: :follower_id, association_foreign_key: :followed_id
    u.has_and_belongs_to_many :followeds, foreign_key: :followed_id, association_foreign_key: :follower_id
  end
  has_and_belongs_to_many :followed_projects, class_name: 'Project',
    join_table: :project_followers
  has_many :access_group_members, dependent: :destroy
  has_many :authorizations, dependent: :destroy
  has_many :blog_posts, dependent: :destroy
  has_many :comments, foreign_key: :user_id, dependent: :destroy
#  has_many :interests, as: :taggable, dependent: :destroy, class_name: 'InterestTag'
  has_many :invitations, class_name: self.to_s, as: :invited_by
  has_many :privacy_rules, as: :privatable_users
  has_many :projects, through: :team_members
  has_many :publications, dependent: :destroy
  has_many :respects, dependent: :destroy, class_name: 'Favorite'
  has_many :respected_projects, through: :respects, source: :project
#  has_many :skills, as: :taggable, dependent: :destroy, class_name: 'SkillTag'
  has_many :team_members
  has_one :avatar, as: :attachable, dependent: :destroy
  has_one :reputation

  attr_accessor :email_confirmation, :skip_registration_confirmation,
    :participant_invite_id, :auth_key_authentified,
    :friend_invite_id, :new_invitation, :invitation_code, :match_by,
    :logging_in_socially
  attr_accessible :email_confirmation, :password, :password_confirmation,
    :remember_me, :avatar_attributes, :projects_attributes,
    :websites_attributes, :invitation_token,
    :first_name, :last_name, :invitation_code,
    :facebook_link, :twitter_link, :linked_in_link, :website_link,
    :blog_link, :categories, :participant_invite_id, :auth_key_authentified,
    :github_link, :invitation_limit, :email, :mini_resume, :city, :country,
    :user_name, :full_name, :roles, :type
  accepts_nested_attributes_for :avatar, :projects, allow_destroy: true

  store :websites, accessors: [:facebook_link, :twitter_link, :linked_in_link, :website_link, :blog_link, :github_link, :google_plus_link]

  validates :name, length: { in: 1..200 }, allow_blank: true
  validates :city, :country, length: { maximum: 50 }, allow_blank: true
  validates :mini_resume, length: { maximum: 160 }, allow_blank: true
  validates :user_name, presence: true, length: { in: 3..100 }, uniqueness: true,
    format: { with: /\A[a-z0-9_]+\z/, message: "accepts only downcase letters, numbers and underscores '_'." }, unless: :being_invited?
  with_options unless: proc { |u| u.skip_registration_confirmation },
    on: :create do |user|
      user.validates :email_confirmation, presence: true
      user.validate :email_matches_confirmation
      user.validate :used_valid_invite_code?
  end
  validate :email_is_unique_for_registered_users, if: :being_invited?

  before_validation :ensure_website_protocol

  scope :with_category, lambda { |category| { conditions: "categories_mask & #{2**CATEGORIES.index(category.to_s)} > 0"} }

  scope :with_role, lambda { |role| { conditions: "roles_mask & #{2**ROLES.index(role.to_s)} > 0"} }

  store :counters_cache, accessors: [:comments_count, :interest_tags_count, :invitations_count, :projects_count, :respects_count, :skill_tags_count, :live_projects_count, :project_views_count]

  parse_as_integers :counters_cache, :comments_count, :interest_tags_count, :invitations_count, :projects_count, :respects_count, :skill_tags_count, :live_projects_count, :project_views_count

  delegate :can?, :cannot?, to: :ability

  is_impressionable counter_cache: true, unique: :session_hash

  taggable :interest_tags, :skill_tags

  serialize :notifications

  self.per_page = 20

  # broadcastable
  has_many :broadcasts, as: :broadcastable

  def broadcast event, context_model_id, context_model_type
    broadcasts.create event: event, context_model_id: context_model_id,
      context_model_type: context_model_type
  end

  # beginning of search methods
  include Tire::Model::Search
  include Tire::Model::Callbacks
  index_name BONSAI_INDEX_NAME

  tire do
    mapping do
      indexes :id,              index: :not_analyzed
      indexes :model,           analyzer: 'keyword', type: 'string'
      indexes :name,            analyzer: 'snowball', boost: 100, type: 'string'
      indexes :user_name,       analyzer: 'snowball', boost: 100, type: 'string'
      indexes :interests,       analyzer: 'snowball'
      indexes :skills,          analyzer: 'snowball'
      indexes :mini_resume,     analyzer: 'snowball'
      indexes :publications,    analyzer: 'snowball'
      indexes :country,         analyzer: 'snowball', type: 'string'
      indexes :city,            analyzer: 'snowball', type: 'string'
      indexes :private,         analyzer: 'keyword'
      indexes :categories,      analyzer: 'keyword'
      indexes :created_at
    end
  end

  def to_indexed_json
    {
      _id: id,
      model: self.class.name,
      name: name,
      user_name: user_name,
      city: city,
      country: country,
      mini_resume: mini_resume,
      publications: publications.pluck(:title),
      interests: interest_tags_string,
      skills: skill_tags_string,
      created_at: created_at,
      private: !accepted_or_not_invited?,
      categories: categories,
    }.to_json
  end
  # end of search methods

  class << self
    def find_for_oauth provider, auth, resource=nil
#    Rails.logger.info 'auth: ' + auth.to_yaml
      case provider
      when 'Facebook'
        uid = auth.uid
        email = auth.info.email
        name = auth.info.name
      when 'Github'
        uid = auth.uid
        email = auth.info.email
        name = auth.info.name
      when 'Google+'
        uid = auth.uid
        email = auth.info.email
        name = auth.info.name
      when 'LinkedIn'
        uid = auth.uid
        email = auth.info.email
        name = auth.info.name
      when 'Twitter'
        uid = auth.uid
        name = auth.info.name
      else
        raise 'Provider #{provider} not handled'
      end

      if user = User.find_for_oauth_by_uid(provider, uid)
        user.match_by = 'uid'
        return user
      end

      if email and user = User.find_by_email(email)
        user.match_by = 'email'
        return user
      end

      # if name and user = User.find_by_full_name(name)
      #   user.match_by = 'name'
      #   return user
      # end
    end

    def find_for_oauth_by_uid(provider, uid)
      where('authorizations.uid = ? AND authorizations.provider = ?', uid.to_s, provider).joins(:authorizations).readonly(false).first
    end

    def new_with_session(params, session)
      super.tap do |user|
        user.extract_from_social_profile params, session
      end
    end
  end

  def self.last_logged_in
    order('last_sign_in_at DESC')
  end

  def self.top
    joins(:reputation).order('reputations.points DESC')
  end

  def ability
    @ability ||= Ability.new(self)
  end

  def add_confirmed_role
    self.roles = roles << 'confirmed_user'
    save
  end

  def auth_key_authentified? project
    auth_key_authentified and participant_invite.try(:project_id) == project.id
  end

  def being_invited?
    new_invitation.present?
  end

  def categories=(categories)
    self.categories_mask = (categories & CATEGORIES).map { |r| 2**CATEGORIES.index(r) }.sum
  end

  def categories
    CATEGORIES.reject { |r| ((categories_mask || 0) & 2**CATEGORIES.index(r)).zero? }
  end

  def counters
    {
      comments: 'comments.count',
      interest_tags: 'interest_tags.count',
      invitations: 'invitations.count',
      live_projects: 'projects.where(private: false).count',
      projects: 'projects.count',
      project_views: 'projects.sum(:impressions_count)',
      respects: 'respects.count',
      skill_tags: 'skill_tags.count',
    }
  end

  # small hack to allow single emails to be invited multiple times
  def email_changed?
    being_invited? ? false : super
  end

  require 'country_iso_translater'
  def extract_from_social_profile params, session
    data = session['devise.provider_data']
    extra = data.extra
    info = data.info
    provider = session['devise.provider']
   logger.info data.to_yaml
   # logger.info provider.to_s
#        logger.info 'user: ' + self.to_yaml
    if info and provider == 'Facebook'
      self.user_name = info.nickname if self.user_name.blank?
      self.email = self.email_confirmation = info.email if self.email.blank?
      self.full_name = info.name if self.full_name.blank?
      self.facebook_link = info.urls['Facebook']
      self.website_link = info.urls['Website']
      begin
        self.city = info['location']['name'].split(',')[0] if self.city.nil?
        self.country = info['location']['name'].split(',')[1].strip if self.country.nil?
        self.city = extra['raw_info']['hometown']['name'].split(',')[0] if self.city.nil?
        self.country = extra['raw_info']['hometown']['name'].split(',')[1].strip if self.country.nil?
        self.build_avatar(remote_file_url: "#{info.image.split('?')[0]}?type=large") unless self.avatar
      rescue => e
        logger.error "Error: " + e.inspect
      end
      self.authorizations.build(
        uid: data.uid,
        provider: 'Facebook',
        name: info.name.to_s,
        link: info.urls['Facebook'],
        token: data.credentials.token
      )
#          logger.info 'user: ' + self.inspect
#          logger.info 'auth: ' + self.authorizations.inspect
    elsif info and provider == 'Github'
      self.user_name = info.nickname if self.user_name.blank?
      self.full_name = info.name if self.full_name.blank?
      self.email = self.email_confirmation = info.email if self.email.blank?
      self.github_link = info.urls['GitHub']
      self.website_link = info.urls['Blog']
      begin
        self.city = info.location.split(',')[0] if self.city.nil?
        self.country = info.location.split(',')[1].strip if self.country.nil?
      rescue => e
        logger.error "Error: " + e.inspect
      end
      self.authorizations.build(
        uid: data.uid,
        provider: 'Gitnub',
        name: info.name.to_s,
        link: info.urls['GitHub'],
        token: data.credentials.token
      )
    elsif info and provider == 'Google+'
      self.user_name = info.email.match(/(.+)@/).try(:[], 1) if self.user_name.blank?
      self.full_name = info.name if self.full_name.blank?
      self.email = self.email_confirmation = info.email if self.email.blank?
      self.google_plus_link = info.urls['Google+']
      begin
        # self.city = info.location.split(',')[0] if self.city.nil?
        # self.country = info.location.split(',')[1].strip if self.country.nil?
        self.build_avatar(remote_file_url: info.image) if info.image and not self.avatar
      rescue => e
        logger.error "Error: " + e.inspect
      end
      self.authorizations.build(
        uid: data.uid,
        provider: 'Google+',
        name: info.name.to_s,
        link: info.urls['Google+'],
        token: data.credentials.token
      )
    elsif info and provider == 'LinkedIn'
      # self.user_name = info.nickname if self.user_name.blank?
      self.full_name = info.first_name.to_s + ' ' + info.last_name.to_s if self.full_name.blank?
      self.email = self.email_confirmation = info.email if self.email.blank?
      self.mini_resume = info.description if self.mini_resume.nil?
      self.linked_in_link = info.urls['public_profile']
      begin
        self.city = info.location.name if self.city.nil?
        self.country =
          SunDawg::CountryIsoTranslater.translate_iso3166_alpha2_to_name(
            info.location.country.code.upcase) if self.country.nil?
        self.build_avatar(remote_file_url: info.image) if info.image and not self.avatar
      rescue => e
        logger.error "Error: " + e.inspect
      end
      self.authorizations.build(
        uid: info.uid,
        provider: 'LinkedIn',
        name: info.first_name.to_s + ' ' + info.last_name.to_s,
        link: info.urls['public_profile'],
        token: data.credentials.token
      )
    elsif info and provider == 'Twitter'
      self.user_name = info.nickname if self.user_name.blank?
      self.full_name = info.name if self.full_name.blank?
      self.mini_resume = info.description if self.mini_resume.nil?
      self.interest_tags_string = info.description.scan(/\#([[:alpha:]]+)/i).join(',')
      self.twitter_link = info.urls['Twitter']
      begin
        self.city = info.location.split(',')[0] if self.city.nil?
        self.country = info.location.split(',')[1].strip if self.country.nil?
        self.build_avatar(remote_file_url: info.image.gsub(/_normal/, '')) unless self.avatar
      rescue => e
        logger.error "Error: " + e.inspect
      end
      self.authorizations.build(
        uid: data.uid,
        provider: 'Twitter',
        name: info.name,
        link: info.urls['Twitter'],
        token: data.credentials.token,
        secret: data.credentials.secret
      )
    end
#          logger.info 'auth: ' + self.authorizations.inspect
    self.password = Devise.friendly_token[0,20]
    self.logging_in_socially = true
  end

  def find_invite_request
    InviteRequest.find_by_email email
  end

  def follow user
    followeds << user unless user.in? followeds# or self == user
  end

  def follow_project project
    followed_projects << project unless project.in? followed_projects
  end

  def has_access_group_permissions? record
    id.in? record.privacy_rules.where(private: false, privatable_user_type: 'AccessGroup').joins('inner join access_groups on access_groups.id = privacy_rules.privatable_user_id').joins('inner join access_group_members on access_group_members.access_group_id = access_groups.id').select('access_group_members.user_id').pluck('access_group_members.user_id') or id.in? record.privacy_rules.where(private: false, privatable_user_type: 'User').pluck(:privatable_user_id)
    #and not id.in? record.privacy_rules.where(private: true).joins('inner join access_groups on access_groups.id = privacy_rules.privatable_user_id').joins('inner join access_group_members on access_group_members.access_group_id = access_groups.id').select('access_group_members.user_id').pluck('access_group_members.user_id')
  end

  def invited?
    invitation_sent_at.present?
  end

  def is? role
    role_symbols.include? role
  end

  def is_following? user
    user.in? followeds
  end

  def is_following_project? project
    followed_projects.where(id: project.id).any?
  end

  def is_team_member? project
    id.in? project.team_members.pluck(:user_id)
  end

  def link_to_provider provider, uid, data=nil
    auth = {
      provider: provider,
      uid: uid,
    }
    if data
      case provider
      when 'Facebook'
        data = data.extra.raw_info
        auth.merge!({
            name: data['first_name'].to_s + ' ' + data['last_name'].to_s,
            link: data['link'],
          })
      when 'Twitter'
        data = data.info
        auth.merge!({
            name: data.name,
            link: data.urls['Twitter'],
          })
      end
    end
    authorizations.create(auth)
  end

  def name
    full_name.present? ? full_name : user_name
  end

  def hide_notification! name
    val = (notifications || []) << name
    self.notifications = val
    save
  end

  def participant_invite
    @participant_invite ||= ParticipantInvite.find_by_id participant_invite_id
  end

  def profile_needs_care?
    live_projects_count.zero? or (country.blank? and city.blank?) or mini_resume.blank? or interest_tags_count.zero? or skill_tags_count.zero? or websites.values.reject{|v|v.nil?}.count.zero?
  end

  def respected? project
    project.id.in? respected_projects.map(&:id)
  end

  def receive_notification? name
    !(notifications and name.in? notifications)
  end

  def roles=(roles)
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end

  def roles
    ROLES.reject { |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero? }
  end

  def role_symbols
    roles.map(&:to_sym)
  end

  def skip_confirmation!
    self.skip_registration_confirmation = true
  end

  def to_param
    user_name
  end

  def to_tracker
    {
      user_id: id,
      user_name: user_name,
    }
  end

  def to_tracker_profile
    {
      created_at: (invitation_accepted_at || created_at),
      comments_count: comments_count,
      email: email,
      has_avatar: avatar.present?,
      has_full_name: full_name.present?,
      has_location: (country.present? || city.present?),
      interests_count: interest_tags_count,
      invitations_count: invitations_count,
      is_admin: is?(:admin),
      live_projects_count: live_projects_count,
      mini_resume_size: mini_resume.try(:length) || 0,
      name: full_name,
      projects_count: projects_count,
      project_views_count: project_views_count,
      respects_count: respects_count,
      skills_count: skill_tags_count,
      username: user_name,
      websites_count: websites.values.reject{|v|v.nil?}.count,
    }
  end

  def unfollow user
    followeds.delete user
  end

  def unfollow_project project
    followed_projects.delete project
  end

  private
    def email_is_unique_for_registered_users
      errors.add :email, 'is already a member' if self.class.where(email: email).where('users.invitation_token IS NULL').any?
    end

    def email_matches_confirmation
      errors.add(:email, "doesn't match confirmation") unless email.blank? or email == email_confirmation
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

    def is_whitelisted?
      return unless email.present?
      errors.add :email, 'is not on our beta list' unless InviteRequest.email_whitelisted? email
    end

    def used_valid_invite_code?
      if invitation_code.present? and invite_code = InviteCode.authenticate(invitation_code)
        self.invite_code_id = invite_code.id
      else
        errors.add :invitation_code, 'is either invalid or expired'
      end
    end

  protected
    def password_required?
      (!persisted? || !password.nil? || !password_confirmation.nil?) && !being_invited?
    end
end
