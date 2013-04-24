class User < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  with_options class_name: 'User', join_table: :follow_relations do |u|
    u.has_and_belongs_to_many :followers, foreign_key: :follower_id, association_foreign_key: :followed_id
    u.has_and_belongs_to_many :followeds, foreign_key: :followed_id, association_foreign_key: :follower_id
  end
  has_and_belongs_to_many :followed_projects, class_name: 'Project',
    join_table: :project_followers
  has_many :blog_posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :projects, through: :team_members
  has_many :publications, dependent: :destroy
  has_many :team_members
  has_one :avatar, as: :attachable, dependent: :destroy

  attr_accessor :email_confirmation, :skip_registration_confirmation
  attr_accessible :email, :email_confirmation, :password, :password_confirmation,
    :remember_me, :roles, :avatar_attributes, :projects_attributes, :websites_attributes,
    :first_name, :last_name, :mini_resume, :city, :country, :user_name, :name,
    :facebook_link, :twitter_link, :linked_in_link, :website_link,
    :blog_link
  accepts_nested_attributes_for :avatar, :projects, allow_destroy: true

  store :websites, accessors: [:facebook_link, :twitter_link, :linked_in_link, :website_link,
    :blog_link
  ]

  validates :name, length: { in: 1..200 }, allow_blank: true
  validates :user_name, length: { in: 3..100 }, uniqueness: true,
    format: { with: /^[a-z0-9_]{3,}$/, message: "accepts only letters, numbers and underscores '_'." }, allow_blank: true
  validates :city, :country, length: { maximum: 50 }, allow_blank: true
  validates :mini_resume, length: { maximum: 160 }, allow_blank: true
  with_options unless: proc { |u| u.skip_registration_confirmation },
    on: :create do |user|
    user.validates :email_confirmation, presence: true
    user.validate :email_matches_confirmation
  end
  before_validation :ensure_website_protocol

  scope :with_role, lambda { |role| { conditions: "roles_mask & #{2**ROLES.index(role.to_s)} > 0"} }

  delegate :can?, :cannot?, to: :ability

  ROLES = %w(admin confirmed_user)

  def ability
    @ability ||= Ability.new(self)
  end

  def add_confirmed_role
    self.roles = roles << 'confirmed_user'
    save
  end

  def follow user
    followeds << user unless user.in? followeds# or self == user
  end

  def follow_project project
    followed_projects << project unless project.in? followed_projects
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

  def name
    full_name ? full_name : user_name
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

  def to_param
    user_name
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
end
