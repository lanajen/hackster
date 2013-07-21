class User < Account
  include Taggable

  devise :database_authenticatable, :registerable, :invitable,
         :recoverable, :rememberable, :trackable, :validatable

  with_options class_name: 'User', join_table: :follow_relations do |u|
    u.has_and_belongs_to_many :followers, foreign_key: :follower_id, association_foreign_key: :followed_id
    u.has_and_belongs_to_many :followeds, foreign_key: :followed_id, association_foreign_key: :follower_id
  end
  has_and_belongs_to_many :followed_projects, class_name: 'Project',
    join_table: :project_followers
  has_many :access_group_members, dependent: :destroy
  has_many :blog_posts, dependent: :destroy
#  has_many :interests, as: :taggable, dependent: :destroy, class_name: 'InterestTag'
  has_many :invitations, class_name: self.to_s, as: :invited_by
  has_many :privacy_rules, as: :privatable_users
  has_many :projects, through: :team_members
  has_many :publications, dependent: :destroy
#  has_many :skills, as: :taggable, dependent: :destroy, class_name: 'SkillTag'
  has_many :team_members
  has_one :avatar, as: :attachable, dependent: :destroy

  attr_accessor :email_confirmation, :skip_registration_confirmation,
    :participant_invite_id, :auth_key_authentified,
    :friend_invite_id, :new_invitation, :invitation_code
  attr_accessible :email_confirmation, :password, :password_confirmation,
    :remember_me, :avatar_attributes, :projects_attributes, :websites_attributes,
    :first_name, :last_name,
    :facebook_link, :twitter_link, :linked_in_link, :website_link,
    :blog_link, :categories, :participant_invite_id, :auth_key_authentified,
    :github_link, :invitation_limit
  accepts_nested_attributes_for :avatar, :projects, allow_destroy: true

  store :websites, accessors: [:facebook_link, :twitter_link, :linked_in_link, :website_link,
    :blog_link, :github_link
  ]

  validates :user_name, presence: true, length: { in: 3..100 }, uniqueness: true,
    format: { with: /^[a-z0-9_]+$/, message: "accepts only downcase letters, numbers and underscores '_'." }, unless: :being_invited?
  with_options unless: proc { |u| u.skip_registration_confirmation },
    on: :create do |user|
      user.validates :email_confirmation, presence: true
      user.validate :email_matches_confirmation
      user.validate :is_whitelisted?
  end
  before_validation :ensure_website_protocol

  scope :with_category, lambda { |category| { conditions: "categories_mask & #{2**CATEGORIES.index(category.to_s)} > 0"} }

  CATEGORIES = [
    'Electrical engineer',
    'Industrial designer',
    'Investor',
    'Manufacturer',
    'Mechanical engineer',
    'Software developer',
  ]

  taggable :interest_tags, :skill_tags

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

  def is_following? user
    user.in? followeds
  end

  def is_following_project? project
    followed_projects.where(id: project.id).any?
  end

  def is_team_member? project
    id.in? project.team_members.pluck(:user_id)
  end

  def participant_invite
    @participant_invite ||= ParticipantInvite.find_by_id participant_invite_id
  end

  def skip_confirmation!
    self.skip_registration_confirmation = true
  end

  def unfollow user
    followeds.delete user
  end

  def unfollow_project project
    followed_projects.delete project
  end

  private
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

  protected
    def password_required?
      (!persisted? || !password.nil? || !password_confirmation.nil?) && !being_invited?
    end
end
