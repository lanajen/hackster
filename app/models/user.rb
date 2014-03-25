class User < ActiveRecord::Base
  include Counter
  include Roles
  include StringParser
  include Taggable

  ROLES = %w(admin confirmed_user beta_tester)
  SUBSCRIPTIONS = {
    'newsletter' => 'Newsletter',
    'other' => 'Other mailings (announcements, tips, feedback...)',
    'new_comment_own' => 'New comment on one of my projects',
    'new_comment_commented' => "New comment on a project I commented on",
    'new_respect_own' => 'Somebody respects one of my projects',
    'new_follow_project' => 'Somebody starts following one of my projects',
    'new_follow_me' => 'Somebody starts following me',
    'follow_project_activity' => 'Activity for a project I follow',
    'follow_user_activity' => 'Activity for a user I follow',
  }

  CATEGORIES = [
    'Electrical engineer',
    'Industrial designer',
    'Investor',
    'Manufacturer',
    'Mechanical engineer',
    'Software developer',
  ]

  devise :database_authenticatable, :registerable, :invitable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable,
         :omniauthable, omniauth_providers: [:facebook, :github, :gplus, :linkedin, :twitter]

  belongs_to :invite_code
  has_many :assignments, through: :promotions
  has_many :assignee_issues, foreign_key: :assignee_id
  has_many :assigned_issues, through: :assignee_issues, source: :issue
  has_many :authorizations, dependent: :destroy
  has_many :blog_posts, dependent: :destroy
  has_many :comments, -> { order created_at: :desc }, foreign_key: :user_id, dependent: :destroy
  has_many :communities, through: :group_ties, source: :group, class_name: 'Community'
  # has_many :courses, through: :promotions  # doesnt work
  has_many :events, through: :hackathons
  has_many :follow_relations
  has_many :followed_projects, source_type: 'Project', through: :follow_relations, source: :followable
  has_many :followed_users, source_type: 'User', through: :follow_relations, source: :followable
  has_many :grades, as: :gradable
  has_many :invert_follow_relations, class_name: 'FollowRelation', as: :followable
  has_many :followers, through: :invert_follow_relations, source: :user
  has_many :group_permissions, through: :groups, source: :granted_permissions
  has_many :group_ties, class_name: 'Member', dependent: :destroy
  has_many :groups, through: :group_ties
  has_many :hackathons, through: :group_ties, source: :group, class_name: 'Hackathon'
  has_many :invitations, class_name: self.to_s, as: :invited_by
  has_many :permissions, as: :grantee
  has_many :projects, through: :teams
  has_many :promotions, through: :group_ties, source: :group, class_name: 'Promotion'
  has_many :respects, dependent: :destroy, class_name: 'Favorite'
  has_many :respected_projects, through: :respects, source: :project
  has_many :team_grades, through: :teams, source: :grades
  has_many :teams, through: :group_ties, source: :group, class_name: 'Team'
  has_one :avatar, as: :attachable, dependent: :destroy
  has_one :reputation, dependent: :destroy

  attr_accessor :email_confirmation, :skip_registration_confirmation,
    :friend_invite_id, :new_invitation, :invitation_code, :match_by,
    :logging_in_socially
  attr_writer :override_devise_notification, :override_devise_model
  attr_accessible :email_confirmation, :password, :password_confirmation,
    :remember_me, :avatar_attributes, :projects_attributes,
    :websites_attributes, :invitation_token,
    :first_name, :last_name, :invitation_code,
    :facebook_link, :twitter_link, :linked_in_link, :website_link,
    :blog_link, :github_link, :google_plus_link, :youtube_link, :categories,
    :github_link, :invitation_limit, :email, :mini_resume, :city, :country,
    :user_name, :full_name, :type, :avatar_id, :subscriptions
  accepts_nested_attributes_for :avatar, :projects, allow_destroy: true

  store :websites, accessors: [:facebook_link, :twitter_link, :linked_in_link, :website_link, :blog_link, :github_link, :google_plus_link, :youtube_link]

  validates :name, length: { in: 1..200 }, allow_blank: true
  validates :city, :country, length: { maximum: 50 }, allow_blank: true
  validates :mini_resume, length: { maximum: 160 }, allow_blank: true
  validates :user_name, presence: true, length: { in: 3..100 }, uniqueness: true,
    format: { with: /\A[a-z0-9_]+\z/, message: "accepts only downcase letters, numbers and underscores '_'." }, unless: :being_invited?
  validates :user_name, exclusion: { in: %w(projects terms privacy admin infringement_policy search users) }
  with_options unless: proc { |u| u.skip_registration_confirmation },
    on: :create do |user|
      user.validates :email_confirmation, presence: true
      user.validate :email_matches_confirmation
      user.validate :used_valid_invite_code?
  end
  validate :email_is_unique_for_registered_users, if: :being_invited?
  validate :website_format_is_valid

  before_validation :ensure_website_protocol
  before_create :subscribe_to_all, unless: proc{|u| u.invitation_token.present? }
  before_save :ensure_authentication_token
  after_invitation_accepted :invitation_accepted

  set_roles :roles, ROLES

  # scope :with_category, ->(category) { where("users.categories_mask & #{2**CATEGORIES.index(category.to_s)} > 0") }

  store :counters_cache, accessors: [:comments_count, :interest_tags_count,
    :invitations_count, :projects_count, :respects_count, :skill_tags_count,
    :live_projects_count, :project_views_count, :followers_count]

  parse_as_integers :counters_cache, :comments_count, :interest_tags_count,
    :invitations_count, :projects_count, :respects_count, :skill_tags_count,
    :live_projects_count, :project_views_count

  delegate :can?, :cannot?, to: :ability

  is_impressionable counter_cache: true, unique: :session_hash

  taggable :interest_tags, :skill_tags

  serialize :notifications

  self.per_page = 20

  # broadcastable
  has_many :broadcasts

  def broadcast event, context_model_id, context_model_type, project_id=nil
    broadcasts.create event: event, context_model_id: context_model_id,
      context_model_type: context_model_type, project_id: project_id,
      broadcastable_type: 'User', broadcastable_id: id
  end

  # beginning of search methods
  include Tire::Model::Search
  include Tire::Model::Callbacks
  index_name ELASTIC_SEARCH_INDEX_NAME

  tire do
    mapping do
      indexes :id,              index: :not_analyzed
      indexes :model,           analyzer: 'keyword', type: 'string'
      indexes :name,            analyzer: 'snowball', boost: 100, type: 'string'
      indexes :user_name,       analyzer: 'snowball', boost: 100, type: 'string'
      indexes :interests,       analyzer: 'snowball'
      indexes :skills,          analyzer: 'snowball'
      indexes :mini_resume,     analyzer: 'snowball'
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

      if email and user = User.where(email: email, invitation_token: nil).first
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
      # overwrite existing invites if any
      if params[:email] and user = where(email: params[:email]).where('invitation_token IS NOT NULL').first
        user.assign_attributes(params)
        user
      # extract social data for omniauth
      elsif session['devise.provider_data']
        user = super.tap do |user|
          user.extract_from_social_profile params, session
        end
        if existing_user = where(email: user.email).where('invitation_token IS NOT NULL').first
          attributes = user.attributes.select{|k,v| k.in? accessible_attributes }
          existing_user.assign_attributes(attributes)
          user = existing_user
        end
        user
      else
        super
      end
    end

    def invitation_accepted_or_not_invited
      where('users.invitation_token IS NULL')
    end
  end

  def self.last_logged_in
    order('last_sign_in_at DESC')
  end

  def self.top
    joins(:reputation).order('reputations.points DESC')
  end

  def self.with_subscription subscription, invert=false
    negate = invert ? 'NOT' : ''
    where("#{negate}(users.subscriptions_mask & #{2**SUBSCRIPTIONS.keys.index(subscription.to_s)} > 0)")
  end

  def ability
    @ability ||= Ability.new(self)
  end

  def add_confirmed_role
    self.roles = roles << 'confirmed_user'
    save
  end

  def all_grades
    grades.includes(:assignment).where(assignments: { private_grades: false }) + team_grades.includes(:assignment).where(assignments: { private_grades: false })
  end

  def all_permissions
    permissions + group_permissions
  end

  def avatar_id=(val)
    self.avatar = Avatar.find_by_id(val)
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

  def community_group_ties
    group_ties.joins(:group).where(groups: { type: %w(Community Event Promotion) }).includes(:group)
  end

  def counters
    {
      comments: 'live_comments.count',
      followers: 'followers.count',
      interest_tags: 'interest_tags.count',
      invitations: 'invitations.count',
      live_projects: 'projects.where(private: false).count',
      projects: 'projects.count',
      project_views: 'projects.sum(:impressions_count)',
      respects: 'respects.count',
      skill_tags: 'skill_tags.count',
    }
  end

  # allows overriding the invitation email template and the model that's sent to the mailer
  def deliver_invitation_with model
    self.override_devise_notification = "invitation_instructions_with_#{model.class.model_name.to_s.underscore}"
    self.override_devise_model = model
    deliver_invitation
  end

  # small hack to allow single emails to be invited multiple times
  def email_changed?
    being_invited? ? false : super
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  require 'country_iso_translater'
  def extract_from_social_profile params, session
    data = session['devise.provider_data']
    extra = data.extra
    info = data.info
    provider = session['devise.provider']
    # logger.info data.to_yaml
    # logger.info provider.to_s
    # logger.info 'user: ' + self.to_yaml
    if info and provider == 'Facebook'
      self.user_name = info.nickname if user_name.blank?
      self.email = self.email_confirmation = info.email if email.blank?
      self.full_name = info.name if full_name.blank?
      self.mini_resume = info.description if mini_resume.blank?
      self.facebook_link = info.urls['Facebook']
      self.website_link = info.urls['Website']
      begin
        if location = info['location']# || extra['raw_info']['hometown']
          self.city = location['name'].split(',')[0] if city.nil?
          self.country = location['name'].split(',')[1].strip if country.nil?
        end
        image_url = "http://graph.facebook.com/#{data.uid}/picture?height=200&width=200"
        self.build_avatar(remote_file_url: image_url) if image_url and not avatar
      rescue => e
        logger.error "Error in extract_from_social_profile (facebook): " + e.inspect
      end
      self.authorizations.build(
        uid: data.uid,
        provider: 'Facebook',
        name: info.name.to_s,
        link: info.urls['Facebook'],
        token: data.credentials.token
      )
    elsif info and provider == 'Github'
      self.user_name = info.nickname if user_name.blank?
      self.full_name = info.name if full_name.blank?
      self.email = self.email_confirmation = info.email if email.blank?
      self.github_link = info.urls['GitHub']
      self.website_link = info.urls['Blog']
      begin
        self.city = info.location.split(',')[0] if city.nil?
        self.country = info.location.split(',')[1].strip if country.nil?
      rescue => e
        logger.error "Error in extract_from_social_profile (github): " + e.inspect
      end
      self.authorizations.build(
        uid: data.uid,
        provider: 'Github',
        name: info.name.to_s,
        link: info.urls['GitHub'],
        token: data.credentials.token
      )
    elsif info and provider == 'Google+'
      self.user_name = info.email.match(/(.+)@/).try(:[], 1).try(:gsub, /[^0-9a-z_]/, '') if user_name.blank?
      self.full_name = info.name if full_name.blank?
      self.email = self.email_confirmation = info.email if email.blank?
      self.google_plus_link = info.urls['Google+']
      begin
        # self.city = info.location.split(',')[0] if city.nil?
        # self.country = info.location.split(',')[1].strip if country.nil?
        self.build_avatar(remote_file_url: info.image) if info.image and not avatar
      rescue => e
        logger.error "Error in extract_from_social_profile (google+): " + e.inspect
      end
      self.authorizations.build(
        uid: data.uid,
        provider: 'Google+',
        name: info.name.to_s,
        link: info.urls['Google+'],
        token: data.credentials.token
      )
    elsif info and provider == 'LinkedIn'
      # self.user_name = info.nickname if user_name.blank?
      self.full_name = info.first_name.to_s + ' ' + info.last_name.to_s if full_name.blank?
      self.email = self.email_confirmation = info.email if email.blank?
      self.mini_resume = info.description if mini_resume.nil?
      self.linked_in_link = info.urls['public_profile']
      begin
        self.city = info.location.name if city.nil?
        self.country =
          SunDawg::CountryIsoTranslater.translate_iso3166_alpha2_to_name(
            info.location.country.code.upcase) if country.nil?
        self.build_avatar(remote_file_url: info.image) if info.image and not avatar
      rescue => e
        logger.error "Error in extract_from_social_profile (linkedin): " + e.inspect
      end
      self.authorizations.build(
        uid: info.uid,
        provider: 'LinkedIn',
        name: info.first_name.to_s + ' ' + info.last_name.to_s,
        link: info.urls['public_profile'],
        token: data.credentials.token
      )
    elsif info and provider == 'Twitter'
      self.user_name = info.nickname if user_name.blank?
      self.full_name = info.name if full_name.blank?
      self.mini_resume = info.description if mini_resume.nil?
      self.interest_tags_string = info.description.scan(/\#([[:alpha:]]+)/i).join(',')
      self.twitter_link = info.urls['Twitter']
      begin
        self.city = info.location.split(',')[0] if city.nil?
        self.country = info.location.split(',')[1].strip if country.nil?
        self.build_avatar(remote_file_url: info.image.gsub(/_normal/, '')) unless avatar
      rescue => e
        logger.error "Error in extract_from_social_profile (twitter): " + e.inspect
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

  # def has_access? project
  #   permissions.where(permissible_type: 'Project', permissible_id: project.id).any? or group_permissions.where(permissible_type: 'Project', permissible_id: project.id).any?
  # end

  def has_notifications?
    notifications.any?
  end

  def hide_notification! name
    val = (notifications || []) << name
    self.notifications = val
    save
  end

  def informal_name
    full_name.present? ? full_name.split(' ')[0] : user_name
  end

  def is? role
    roles.map(&:to_sym).include? role
  end

  def following? followable
    case followable
    when Project
      followable.in? followed_projects
    when User
      followable.in? followed_users
    end
  end

  def is_active_member? group
    group.members.invitation_accepted_or_not_invited.where(user_id: id).first
  end

  def is_member? group
    group.members.where(user_id: id).first
  end

  def is_staff? project
    project.try(:assignment).try(:promotion).try(:members).try(:with_group_roles, %w(ta professor)).try(:where, user_id: id).any?
  end

  def is_team_member? project, all=true
    members = project.team_members.where(user_id: id)
    members = members.request_accepted_or_not_requested unless all
    members.first
  end

  def link_to_provider provider, uid, data=nil
    auth = {
      provider: provider,
      uid: uid,
    }
    if data and data = data.info
      case provider
      when 'Facebook'
        auth.merge!({
            name: data.name,
            link: data.urls['Facebook'],
          })
      when 'Github'
        auth.merge!({
          name: data.name.to_s,
          link: data.urls['GitHub'],
          })
      when 'Google+'
        auth.merge!({
          name: data.name.to_s,
          link: data.urls['Google+'],
          })
      when 'Twitter'
        auth.merge!({
            name: data.name,
            link: data.urls['Twitter'],
          })
      end
    end
    authorizations.create(auth)
  end

  def linked_to_project_via_group? project
    sql = "SELECT projects.* FROM groups INNER JOIN permissions ON permissions.grantee_id = groups.id AND permissions.permissible_type = 'Project' AND permissions.grantee_type = 'Group' INNER JOIN projects ON projects.id = permissions.permissible_id INNER JOIN members ON groups.id = members.group_id WHERE members.user_id = ? AND projects.id = ?;"
    sql2 = "SELECT members.* FROM members INNER JOIN groups ON members.group_id = groups.id WHERE members.user_id = ? AND groups.type = 'Promotion' AND groups.id = (SELECT assignments.promotion_id FROM assignments WHERE assignments.id = ?)"
    sql3 = "SELECT members.* FROM members INNER JOIN groups ON members.group_id = groups.id WHERE members.user_id = ? AND groups.type = 'Event' AND groups.id = ?"
    Project.find_by_sql([sql, id, project.id]).any? or project.collection_id.present? and (Member.find_by_sql([sql2, id, project.collection_id]).any? or Member.find_by_sql([sql3, id, project.collection_id]).any?)
  end

  def live_comments
    comments.by_commentable_type(Project).where("projects.private = 'f'")
  end

  def name
    full_name.present? ? full_name : user_name
  end

  def notifications
    return @notifications if @notifications

    @notifications = []
    group_ties.each do |group_tie|
      @notifications << {
        message: "You have been invited to join #{group_tie.group.name}. Click to visit this group.",
        link: group_tie.group,
      } if group_tie.invitation_pending?
    end
    @notifications
  end

  # def add_notification message, link=nil
  #   notifications << { message: message, link: link }
  # end

  # def delete_notification message
  #   @notifications.delete message
  # end

  def profile_needs_care?
    live_projects_count.zero? or (country.blank? and city.blank?) or mini_resume.blank? or interest_tags_count.zero? or skill_tags_count.zero? or websites.values.reject{|v|v.nil?}.count.zero?
  end

  def respected? project
    project.id.in? respected_projects.map(&:id)
  end

  def receive_notification? name
    !(notifications and name.in? notifications)
  end

  def reset_authentication_token
    update_attribute(:authentication_token, nil)
    # the new token is set automatically on save
  end

  # allows overriding the email template and model that are sent to devise mailer
  def send_devise_notification(notification, *args)
    notification = @override_devise_notification if @override_devise_notification.present?
    model = @override_devise_model || self
    devise_mailer.send(notification, model, *args).deliver
  end

  def send_reset_password_instructions
    super if invitation_token.nil?
  end

  def skip_confirmation!
    self.skip_registration_confirmation = true
  end

  def subscribe_to_all
    self.subscriptions = SUBSCRIPTIONS.keys
  end

  def subscriptions=(subscriptions)
    self.subscriptions_mask = (subscriptions & SUBSCRIPTIONS.keys).map { |r| 2**SUBSCRIPTIONS.keys.index(r) }.sum
  end

  def subscriptions
    SUBSCRIPTIONS.keys.reject { |r| ((subscriptions_mask || 0) & 2**SUBSCRIPTIONS.keys.index(r)).zero? }
  end

  def subscription_symbols
    subscriptions.map(&:to_sym)
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

    def generate_authentication_token
      loop do
        token = Devise.friendly_token
        break token unless User.where(authentication_token: token).first
      end
    end

    def invitation_accepted
      notify_observers(:after_invitation_accepted)
    end

    def is_whitelisted?
      return unless email.present?
      errors.add :email, 'is not on our beta list' unless InviteRequest.email_whitelisted? email
    end

    def website_format_is_valid
      websites.each do |type, url|
        next if url.blank?
        errors.add type.to_sym, 'is not a valid URL' unless url.downcase =~ URL_REGEXP
      end
    end

    def used_valid_invite_code?
      return unless invitation_code.present?
      if invite_code = InviteCode.authenticate(invitation_code)
        self.invite_code_id = invite_code.id
      else
        errors.add :invitation_code, 'is either invalid or expired'
      end
    end

  protected
    # overwrites devise
    def confirmation_required?
      false
    end

    def password_required?
      (!persisted? || !password.nil? || !password_confirmation.nil?) && !being_invited?
    end
end
