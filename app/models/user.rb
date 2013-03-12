class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  with_options class_name: 'User', join_table: :follow_relations do |u|
    u.has_and_belongs_to_many :followers, foreign_key: :follower_id, association_foreign_key: :followed_id
    u.has_and_belongs_to_many :followeds, foreign_key: :followed_id, association_foreign_key: :follower_id
  end
  has_one :avatar, as: :attachable
  has_many :projects
  has_many :websites

  attr_accessor :email_confirmation, :skip_registration_confirmation
  attr_accessible :email, :email_confirmation, :password, :password_confirmation,
    :remember_me, :roles, :avatar_attributes, :projects_attributes, :websites_attributes,
    :first_name, :last_name, :bio, :city, :country, :user_name
  accepts_nested_attributes_for :avatar, :projects, :websites

  validates :first_name, :last_name, length: { in: 1..100 }, allow_blank: true
  validates :user_name, length: { in: 3..100 }, allow_blank: true
  validates :city, :country, length: { maximum: 50 }, allow_blank: true
  with_options unless: proc { |u| u.skip_registration_confirmation },
    on: :create do |user|
    user.validates :email_confirmation, presence: true
    user.validate :email_matches_confirmation
  end

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
    followeds << user
  end

  def is? role
    role_symbols.include? role
  end

  def name
    first_name + ' ' + last_name
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

  def unfollow user
    followeds.delete user
  end

  private
    def email_matches_confirmation
      errors.add(:email, "doesn't match confirmation") unless email.blank? or email == email_confirmation
    end
end
