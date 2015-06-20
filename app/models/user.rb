class User < ActiveRecord::Base

  include EditableSlug
  include HstoreColumn
  include HstoreCounter
  include Roles
  include Taggable
  include WebsitesColumn

  include Rewardino::Nominee

  ROLES = %w(admin confirmed_user beta_tester moderator)
  SUBSCRIPTIONS = {
    email: {
      'newsletter' => 'Newsletter',
      'other' => 'Other mailings (announcements, tips, feedback...)',
      'new_comment_own' => 'New comment on one of my projects',
      'new_comment_commented' => "New comment on a project I commented on",
      'new_respect_own' => 'Somebody respects one of my projects',
      'new_follow_project' => 'Somebody starts following one of my projects',
      'new_follow_me' => 'Somebody starts following me',
      'follow_project_activity' => 'Activity for a project I follow',
      'follow_user_activity' => 'Activity for a user I follow',
      'follow_platform_activity' => 'Activity for a platform I follow',
      'follow_list_activity' => 'Activity for a list I follow',
      'new_badge' => 'I receive a new badge',
      'new_message' => 'I receive a new private message',
      'project_approved' => 'My project has been approved',
      'new_comment_update' => 'Somebody comments on one of my updates',
      'new_comment_update_commented' => 'Somebody comments on an update I commented on',
      'new_like' => 'Somebody likes one of my updates or comments',
      'new_mention' => 'Somebody mentions me in an update or comment',
    },
    web: {
      'new_comment_own' => 'New comment on one of my projects',
      'new_comment_commented' => "New comment on a project I commented on",
      'new_respect_own' => 'Somebody respects one of my projects',
      'new_follow_project' => 'Somebody starts following one of my projects',
      'new_follow_me' => 'Somebody starts following me',
      'follow_project_activity' => 'Activity for a project I follow',
      'follow_user_activity' => 'Activity for a user I follow',
      'follow_platform_activity' => 'Activity for a platform I follow',
      'follow_list_activity' => 'Activity for a list I follow',
      'new_badge' => 'I receive a new badge',
      'new_message' => 'I receive a new private message',
      'project_approved' => 'My project has been approved',
      'new_comment_update' => 'Somebody comments on one of my updates',
      'new_comment_update_commented' => 'Somebody comments on an update I commented on',
      'new_like' => 'Somebody likes one of my updates or comments',
      'new_mention' => 'Somebody mentions me in an update or comment',
    }
  }
  USER_NAME_WORDS_LIST1 = %w(acid ada agent alien chell colossus crash cyborg doc ender enigma hal isambard jarvis kaneda leela morpheus neo nikola oracle phantom radio silicon sim starbuck straylight synergy tank tetsuo trinity zero)
  USER_NAME_WORDS_LIST2 = %w(algorithm blue brunel burn clone cool core curie davinci deckard driver energy fett flynn formula gibson glitch grid hawking jaunte newton overdrive override phreak plasma ripley skywalker tesla titanium uhura wiggin)

  editable_slug :user_name

  devise :database_authenticatable, :registerable, :invitable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable,
         :omniauthable, omniauth_providers: [:facebook, :github, :gplus,
          :linkedin, :twitter, :windowslive]

  belongs_to :invite_code
  has_many :addresses, -> { order(id: :desc) }, as: :addressable
  has_many :assignments, through: :promotions
  has_many :assignee_issues, foreign_key: :assignee_id
  has_many :assigned_issues, through: :assignee_issues, source: :issue
  has_many :authorizations, dependent: :destroy
  has_many :blog_posts, dependent: :destroy
  has_many :comments, -> { order created_at: :desc }, foreign_key: :user_id, dependent: :destroy
  has_many :comment_likes, class_name: 'Respect', through: :comments, source: :likes
  has_many :communities, through: :group_ties, source: :group, class_name: 'Community'
  # has_many :courses, through: :promotions  # doesnt work
  has_many :events, through: :group_ties, source: :group, class_name: 'Event'
  has_many :follow_relations, dependent: :destroy
  has_many :followed_groups, -> { order('groups.full_name ASC') }, source_type: 'Group', through: :follow_relations, source: :followable
  has_many :followed_lists, -> { order('groups.full_name ASC').where("groups.type = 'List'") }, source_type: 'Group', through: :follow_relations, source: :followable
  has_many :followed_platforms, -> { order('groups.full_name ASC').where("groups.type = 'Platform'") }, source_type: 'Group', through: :follow_relations, source: :followable
  has_many :followed_users, source_type: 'User', through: :follow_relations, source: :followable
  has_many :grades, as: :gradable
  has_many :invert_follow_relations, class_name: 'FollowRelation', as: :followable
  has_many :followers, through: :invert_follow_relations, source: :user
  has_many :group_permissions, through: :groups, source: :granted_permissions
  has_many :group_ties, class_name: 'Member', dependent: :destroy
  has_many :groups, through: :group_ties
  has_many :hackathons, through: :events
  has_many :hacker_spaces_group_ties, -> { where(type: 'HackerSpaceMember') }, class_name: 'HackerSpaceMember', dependent: :destroy
  has_many :hacker_spaces, through: :hacker_spaces_group_ties, source: :group, class_name: 'HackerSpace'
  has_many :hardware_parts, -> { order('parts.name').where(parts: { type: 'HardwarePart' }) }, source_type: 'Part', through: :follow_relations, source: :followable
  has_many :invitations, class_name: self.to_s, as: :invited_by do
    def accepted
      where("users.invitation_accepted_at IS NOT NULL")
    end
  end
  has_many :lists_group_ties, -> { where(type: 'ListMember') }, class_name: 'ListMember', dependent: :destroy
  has_many :lists, through: :lists_group_ties, source: :group, class_name: 'List'
  has_many :notifications, through: :receipts, source: :receivable, source_type: 'Notification'
  has_many :orders, -> { order :placed_at }
  has_many :owned_parts, -> { order('parts.name') }, source_type: 'Part', through: :follow_relations, source: :followable
  has_many :permissions, as: :grantee
  has_many :platforms, -> { order('groups.full_name ASC') }, through: :group_ties, source: :group, class_name: 'Platform'
  has_many :projects, -> { where("projects.guest_name IS NULL OR projects.guest_name = ''") }, through: :teams
  has_many :promotions, through: :group_ties, source: :group, class_name: 'Promotion'
  has_many :promotion_group_ties, -> { where(type: 'PromotionMember') }, class_name: 'PromotionMember', dependent: :destroy
  has_many :receipts, dependent: :destroy do
    def for_notifications
      joins("INNER JOIN notifications ON notifications.id = receipts.receivable_id AND receipts.receivable_type = 'Notification'")
    end
  end
  has_many :replicated_projects, source_type: 'Project', through: :follow_relations, source: :followable
  has_many :respects, dependent: :destroy
  has_many :respected_projects, through: :respects, source: :respectable, source_type: 'Project'
  has_many :team_grades, through: :teams, source: :grades
  has_many :teams, through: :group_ties, source: :group, class_name: 'Team'
  has_many :thoughts
  has_many :thought_likes, class_name: 'Respect', through: :thoughts, source: :likes
  has_many :user_activities
  has_one :avatar, as: :attachable, dependent: :destroy
  has_one :reputation, dependent: :destroy
  has_one :slug, as: :sluggable, dependent: :destroy, class_name: 'SlugHistory'

  attr_accessor :email_confirmation, :skip_registration_confirmation,
    :friend_invite_id, :new_invitation, :invitation_code, :match_by,
    :logging_in_socially, :skip_password
  attr_writer :override_devise_notification, :override_devise_model,
    :invitation_message
  attr_accessible :email_confirmation, :password, :password_confirmation,
    :remember_me, :avatar_attributes, :projects_attributes,
    :websites_attributes, :invitation_token,
    :first_name, :last_name, :invitation_code, :categories,
    :invitation_limit, :email, :mini_resume, :city, :country,
    :user_name, :full_name, :type, :avatar_id, :enable_sharing,
    :email_subscriptions, :web_subscriptions
  accepts_nested_attributes_for :avatar, :projects, allow_destroy: true

  validates :name, length: { in: 1..200 }, allow_blank: true
  validates :city, :country, length: { maximum: 50 }, allow_blank: true
  validates :mini_resume, length: { maximum: 160 }, allow_blank: true
  validates :user_name, :new_user_name, presence: true, if: proc{|u| u.persisted? }
  validates :user_name, :new_user_name, length: { in: 3..100 },
    format: { with: /\A[a-zA-Z0-9_\-]+\z/, message: "accepts only letters, numbers, underscores '_' and dashes '-'." }, allow_blank: true
  validates :user_name, :new_user_name, exclusion: { in: %w(projects terms privacy admin infringement_policy search users communities hackerspaces hackers lists products about store api talk) }
  with_options unless: proc { |u| u.skip_registration_confirmation },
    on: :create do |user|
      user.validates :email_confirmation, presence: true
      user.validate :email_matches_confirmation
      user.validate :used_valid_invite_code?
  end
  # validate :email_is_unique_for_registered_users, if: :being_invited?
  validate :website_format_is_valid
  validate :user_name_is_unique, unless: :being_invited?

  # before_validation :generate_password, if: proc{|u| u.skip_password }
  before_validation :ensure_website_protocol
  before_validation :generate_user_name, if: proc{|u| u.user_name.blank? and u.new_user_name.blank? and !u.invited_to_sign_up? }
  before_create :subscribe_to_all, unless: proc{|u| u.invitation_token.present? }
  before_save :ensure_authentication_token
  after_invitation_accepted :invitation_accepted

  set_roles :roles, ROLES

  counters_column :counters_cache, long_format: true
  has_counter :accepted_invitations, 'invitations.accepted.count'
  has_counter :badges_green, 'badges(:green).count'
  has_counter :badges_bronze, 'badges(:bronze).count'
  has_counter :badges_silver, 'badges(:silver).count'
  has_counter :badges_gold, 'badges(:gold).count'
  has_counter :comments, 'live_comments.count'
  has_counter :feed_likes, 'comment_likes.count + thought_likes.count'
  has_counter :followed_users, 'followed_users.count'
  has_counter :followers, 'followers.count'
  has_counter :hacker_spaces, 'hacker_spaces.count'
  has_counter :interest_tags, 'interest_tags.count'
  has_counter :invitations, 'invitations.count'
  has_counter :live_projects, 'projects.where(private: false).count'
  has_counter :live_hidden_projects, 'projects.where(private: false, hide: true).count'
  has_counter :owned_parts, 'owned_parts.count'
  has_counter :platforms, 'followed_platforms.count'
  has_counter :project_platforms, 'project_platforms.count'
  has_counter :popularity_points, 'projects.live.map{|p| p.team_members_count > 0 ? p.popularity_counter / p.team_members_count : 0 }.sum'
  has_counter :projects, 'projects.count'
  has_counter :project_respects, 'projects.includes(:respects).count(:respects)'
  has_counter :project_views, 'projects.sum(:impressions_count)'
  has_counter :replicated_projects, 'replicated_projects.count'
  has_counter :reputation, 'reputation_events.sum(:points)'
  has_counter :respects, 'respects.count'
  has_counter :skill_tags, 'skill_tags.count'
  has_counter :suggested_platforms, 'suggested_platforms.count'
  has_counter :thoughts, 'thoughts.count'
  has_counter :websites, 'websites.values.select{|v| v.present? }.size'

  store :properties, accessors: []
  hstore_column :properties, :has_unread_notifications, :boolean

  has_websites :websites, :facebook, :twitter, :linked_in, :website, :blog,
    :github, :google_plus, :youtube, :instagram, :flickr, :reddit, :pinterest

  delegate :can?, :cannot?, to: :ability

  is_impressionable counter_cache: true, unique: :session_hash

  taggable :interest_tags, :skill_tags

  self.per_page = 20

  # broadcastable
  has_many :broadcasts

  def broadcast event, context_model_id, context_model_type, project_id=nil
    broadcasts.create event: event, context_model_id: context_model_id,
      context_model_type: context_model_type, project_id: project_id,
      broadcastable_type: 'User', broadcastable_id: id
  end

  # beginning of search methods
  include TireInitialization
  has_tire_index '!accepted_or_not_invited?'

  tire do
    mapping do
      indexes :id,              index: :not_analyzed
      indexes :name,            analyzer: 'snowball', boost: 100, type: 'string'
      indexes :user_name,       analyzer: 'snowball', boost: 100, type: 'string'
      indexes :interests,       analyzer: 'snowball'
      indexes :skills,          analyzer: 'snowball'
      indexes :mini_resume,     analyzer: 'snowball'
      indexes :country,         analyzer: 'snowball', type: 'string'
      indexes :city,            analyzer: 'snowball', type: 'string'
      indexes :created_at
    end
  end

  def to_indexed_json
    {
      _id: id,
      model: self.class.name.underscore,
      name: name,
      user_name: user_name,
      city: city,
      country: country,
      mini_resume: mini_resume,
      interests: interest_tags_string,
      skills: skill_tags_string,
      created_at: created_at,
      popularity: reputation.try(:points),
    }.to_json
  end

  def self.index_all
    index.import invitation_accepted_or_not_invited
  end
  # end of search methods

  class << self
    def new_with_session(params, session)
      # overwrite existing invites if any
      if params[:email] and user = where(email: params[:email]).where('invitation_token IS NOT NULL').first
        user.assign_attributes(params)
        user
      # extract social data for omniauth
      elsif session['devise.provider_data']
        user = super.tap do |user|
          SocialProfileBuilder.new(user).extract_from_social_profile params, session
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

    def user_name_set
      where("users.user_name IS NOT NULL AND users.user_name <> ''")
    end
  end

  def self.hackster
    where "users.email ILIKE '%@user.hackster.io'"
  end

  def self.not_hackster
    where.not "users.email ILIKE '%@user.hackster.io'"
  end

  def self.last_logged_in
    order('last_sign_in_at DESC')
  end

  def self.not_admin
    without_roles('admin')
  end

  def self.top
    joins(:reputation).order('reputations.points DESC')
  end

  def self.with_at_least_one_action
    where(id: (User.joins(:follow_relations).where("follow_relations.user_id = users.id").distinct('users.id').pluck(:id) + User.joins(:projects).distinct('users.id').pluck(:id) + User.joins(:respects).distinct('users.id').pluck(:id) + User.joins(:comments).distinct('users.id').pluck(:id)).uniq)
  end

  def self.with_subscription notification_type, subscription, invert=false
    negate = invert ? 'NOT ' : ''
    const = SUBSCRIPTIONS[notification_type.to_sym]
    where("#{negate}(CAST(users.subscriptions_masks -> '#{notification_type}' AS INTEGER) & #{2**const.keys.index(subscription.to_s)} > 0)")
  end

  def ability
    @ability ||= Ability.new(self)
  end

  def active_profile?
    user_name.present? and invitation_token.nil?
  end

  def accept_invitation!
    generate_user_name if user_name.blank?
    super
  end

  def add_confirmed_role
    self.roles = roles << 'confirmed_user'
    save
  end

  def after_confirmation
    add_confirmed_role
  end

  def all_grades
    grades.joins('INNER JOIN project_collections ON grades.project_id = project_collections.project_id INNER JOIN assignments ON project_collections.collectable_id = assignments.id').where("project_collections.collectable_type = 'Assignment'").where(assignments: { private_grades: false }) + team_grades.joins('INNER JOIN project_collections ON grades.project_id = project_collections.project_id INNER JOIN assignments ON project_collections.collectable_id = assignments.id').where("project_collections.collectable_type = 'Assignment'").where(assignments: { private_grades: false })
  end

  def all_permissions
    permissions + group_permissions
  end

  def avatar_id=(val)
    self.avatar = Avatar.find_by_id(val)
  end

  def badges_count
    badges_green_count + badges_bronze_count + badges_silver_count + badges_gold_count
  end

  def being_invited?
    new_invitation.present?
  end

  def community_group_ties
    group_ties.joins(:group).where(groups: { type: %w(Community Event Promotion) }).includes(:group)
  end

  def confirmed?
    !!confirmed_at and unconfirmed_email.nil?
  end

  def default_user_name?
    !!(user_name =~ /.+\-.+\-[0-9]+/)
  end

  # allows overriding the invitation email template and the model that's sent to the mailer
  # options: model, message
  def deliver_invitation_with options={}
    if model = options[:model]
      # self.override_devise_notification = "invitation_instructions_with_#{model.class.model_name.to_s.underscore}"
      self.override_devise_notification = "invitation_instructions_with_member"
      self.override_devise_model = model
    end
    if message = options[:personal_message]
      self.invitation_message = message
    end
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

  def find_invite_request
    InviteRequest.find_by_email email
  end

  # def has_access? project
  #   permissions.where(permissible_type: 'Project', permissible_id: project.id).any? or group_permissions.where(permissible_type: 'Project', permissible_id: project.id).any?
  # end

  def generate_password
    self.password = Devise.friendly_token.first(8)
  end

  def generate_user_name
    random_user_name = self.class.generate_random_user_name

    count = self.class.where("users.user_name ILIKE '#{random_user_name}-%'").count

    self.user_name = "#{random_user_name}-#{count + 1}"
  end

  def self.generate_random_user_name
    "#{USER_NAME_WORDS_LIST1.sample}-#{USER_NAME_WORDS_LIST2.sample}"
  end

  def has_notifications?
    notifications.any?
  end

  def has_unread_notifications?
    has_unread_notifications
  end

  def informal_name
    full_name.present? ? full_name.split(' ')[0] : user_name
  end

  def is? *tested_roles
    (roles.map(&:to_sym) & tested_roles).any?
  end

  def is_challenge_entrant? challenge
    self.in? challenge.entrants
  end

  def is_connected_with? provider_name
    provider_name.to_s.downcase.in? authorizations.pluck(:provider).map{|p| p.downcase }
  end

  def following? followable
    case followable
    when Group
      followable.in? followed_groups
    when Part
      followable.in? owned_parts
    when Project
      followable.in? replicated_projects
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

  def is_platform_member? platform
    PlatformMember.where(group_id: platform.id, user_id: id).any?
  end

  def link_to_provider provider, uid, data=nil
    auth = {
      name: data.name,
      provider: provider,
      uid: uid,
    }

    link = if data and data = data.info
       data.urls.try(:[], provider)
     end

    if link
      auth[:link] = link
      link_name = case provider
      when 'Google+'
        'google_plus'
      else
        provider.to_s.underscore
      end
      update_attribute "#{link_name}_link", link
    end
    authorizations.create(auth)
  end

  def linked_to_project_via_group? project
    # sql = "SELECT projects.* FROM groups INNER JOIN permissions ON permissions.grantee_id = groups.id AND permissions.permissible_type = 'Project' AND permissions.grantee_type = 'Group' INNER JOIN projects ON projects.id = permissions.permissible_id INNER JOIN members ON groups.id = members.group_id WHERE members.user_id = ? AND projects.id = ? LIMIT 1;"
    # sql2 = "SELECT members.* FROM members INNER JOIN groups ON members.group_id = groups.id WHERE members.user_id = ? AND groups.type = 'Promotion' AND groups.id = (SELECT assignments.promotion_id FROM assignments WHERE assignments.id = ?) LIMIT 1"
    # sql3 = "SELECT members.* FROM members INNER JOIN groups ON members.group_id = groups.id WHERE members.user_id = ? AND groups.type = 'Event' AND groups.id = ? LIMIT 1"
    # Project.find_by_sql([sql, id, project.id]).first or project.collection_id.present? and (Member.find_by_sql([sql2, id, project.collection_id]).first or Member.find_by_sql([sql3, id, project.collection_id]).first)

    sql2 = "SELECT members.* FROM members INNER JOIN groups ON members.group_id = groups.id INNER JOIN assignments ON assignments.promotion_id = groups.id INNER JOIN project_collections ON project_collections.collectable_id = assignments.id WHERE project_collections.collectable_type = 'Assignment' AND groups.type = 'Promotion' AND members.user_id = ? AND project_collections.project_id = ? LIMIT 1"

    sql4 = "SELECT members.* FROM members INNER JOIN groups ON members.group_id = groups.id INNER JOIN project_collections ON project_collections.collectable_id = groups.id WHERE project_collections.collectable_type = 'Group' AND members.user_id = ? AND project_collections.project_id = ? LIMIT 1"
    Member.find_by_sql([sql4, id, project.id]).first or Member.find_by_sql([sql2, id, project.id]).first
  end

  def live_comments
    comments.by_commentable_type(Project).where("projects.private = 'f'")
  end

  def live_visible_projects_count
    live_projects_count.to_i - live_hidden_projects_count.to_i
  end

  def mark_has_unread_notifications!
    update_attribute :has_unread_notifications, true if !has_unread_notifications?
  end

  def mark_has_no_unread_notifications!
    update_attribute :has_unread_notifications, false if has_unread_notifications?
  end

  def name
    full_name.present? ? full_name : user_name
  end

  def profile_needs_care?
    # live_projects_count.zero? or (country.blank? and city.blank?) or mini_resume.blank? or interest_tags_count.zero? or skill_tags_count.zero? or websites.values.reject{|v|v.nil?}.count.zero?
    (country.blank? and city.blank?) or mini_resume.blank? or full_name.blank? or default_user_name? or avatar.nil?
  end

  def profile_complete?
    country.present? and city.present? and mini_resume.present? and (full_name.present? or !default_user_name?) and avatar.present? and interest_tags_count > 0 and skill_tags_count > 0 and websites.values.reject{|v|v.nil?}.count > 0
  end

  def project_platforms
    Platform.distinct.joins(:project_collections).joins(project_collections: :project).joins(project_collections: { project: :team }).joins(project_collections: { project: { team: :members }}).where(members: { user_id: id }, projects: { private: false })
  end

  def respected? project
    project.id.in? respected_projects.map(&:id)
  end

  def reset_authentication_token
    update_attribute(:authentication_token, nil)
    # the new token is set automatically on save
  end

  def security_token
    Digest::MD5.hexdigest(id.to_s)
  end

  # allows overriding the email template and model that are sent to devise mailer
  def send_devise_notification(notification, *args)
    notification = @override_devise_notification if @override_devise_notification.present?
    model = @override_devise_model || self
    if @invitation_message.present?
      if args[1]
        args[1][:personal_message] = @invitation_message
      else
        args[1] = { personal_message: @invitation_message }
      end
    end
    devise_mailer.send(notification, model, *args).deliver_now
  end

  def send_reset_password_instructions
    super if invitation_token.nil?
  end

  def simplified_signup?
    encrypted_password.blank? and confirmed_at.nil?
  end

  def skip_confirmation!
    self.skip_registration_confirmation = true
  end

  def skip_password!
    self.skip_password = true
  end

  def simplify_signup!
    skip_confirmation!
    skip_password!
    @override_devise_notification = 'confirmation_instructions_simplified_signup'
  end

  def skip_password?
    skip_password
  end

  def email_subscriptions
    subscriptions_for 'email'
  end

  def email_subscriptions=(val)
    set_subscriptions_for 'email', val
  end

  def web_subscriptions
    subscriptions_for 'web'
  end

  def web_subscriptions=(val)
    set_subscriptions_for 'web', val
  end

  def subscribe_to_all
    %w(email web).each do |notification_type|
      set_subscriptions_for notification_type, subscriptions_const_for(notification_type).keys
    end
  end

  def subscribed_to? notification_type, subscription
    subscription.in? subscriptions_for(notification_type)
  end

  def set_subscriptions_for notification_type, subscriptions
    const = subscriptions_const_for(notification_type)
    set_subscriptions_mask_for notification_type, (subscriptions & const.keys).map { |r| 2**const.keys.index(r) }.sum
  end

  def set_subscriptions_mask_for notification_type, mask_value
    self.subscriptions_masks[notification_type.to_s] = mask_value
  end

  def subscriptions_mask_for notification_type
    subscriptions_masks[notification_type.to_s].to_i
  end

  def subscriptions_const_for notification_type
    SUBSCRIPTIONS[notification_type.to_sym]
  end

  def subscription_symbols_for notification_type
    subscriptions_for(notification_type).map(&:to_sym)
  end

  def subscriptions_for notification_type
    mask = subscriptions_mask_for(notification_type)
    const = subscriptions_const_for(notification_type)
    const.keys.reject { |r| ((mask || 0) & 2**const.keys.index(r)).zero? }
  end

  def project_for_assignment assignment
    projects.joins(:project_collections).where(project_collections: { collectable_id: assignment.id, collectable_type: 'Assignment' })
  end

  def created_project_for_assignment? assignment
    project_for_assignment(assignment).any?
  end

  def submitted_project_to_assignment? assignment
    project_for_assignment(assignment).where("projects.assignment_submitted_at IS NOT NULL").any?
  end

  def student_assignments
    Assignment.where(promotion_id: promotion_group_ties.with_group_roles('student').pluck(:group_id))
  end

  def suggested_platforms
    project_platforms - followed_platforms
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
      social_provider: authorizations.first.try(:provider),
      username: user_name,
      websites_count: websites.values.reject{|v|v.nil?}.count,
    }
  end

  def total_orders_this_month
    @total_orders_this_month ||= orders.valid.this_month.sum("CAST(counters_cache -> 'order_lines_count' AS INTEGER)")
  end

  def twitter_handle
    return unless twitter_link.present?

    handle = twitter_link.match(/twitter.com\/(.+)/).try(:[], 1)
    handle.present? ? "@#{handle}" : nil
  end

  def update_last_seen! time=nil
    update_column :last_seen_at, time || Time.now
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

    def user_name_is_unique
      return unless user_name.present?

      slug = SlugHistory.where("LOWER(slug_histories.value) = ?", new_user_name.downcase).first
      if slug and slug.sluggable != self
        errors.add :new_user_name, 'is already taken'
        errors.add :user_name, 'is already taken'
      end
    end

  protected
    # overwrites devise
    def confirmation_required?
      false
    end

    def password_required?
      (!skip_password? && !persisted? && !being_invited?) || !password.nil? || !password_confirmation.nil?
    end
end
