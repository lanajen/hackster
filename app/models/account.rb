class Account < ActiveRecord::Base
  self.table_name = :users

  has_many :comments, foreign_key: :user_id, dependent: :destroy
  has_one :avatar, as: :attachable, dependent: :destroy

  attr_accessible :email, :mini_resume, :city, :country, :user_name, :full_name,
    :roles, :type

  validates :name, length: { in: 1..200 }, allow_blank: true
  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: /^\b[a-z0-9._%-\+]+@[a-z0-9.-]+\.[a-z]{2,4}\b$/, message: 'is not a valid email address'}
  validates :user_name, presence: true, length: { in: 3..100 }, uniqueness: true,
    format: { with: /^[a-z0-9_]+$/, message: "accepts only downcase letters, numbers and underscores '_'." }
  validates :city, :country, length: { maximum: 50 }, allow_blank: true
  validates :mini_resume, length: { maximum: 160 }, allow_blank: true

  scope :with_role, lambda { |role| { conditions: "roles_mask & #{2**ROLES.index(role.to_s)} > 0"} }

  ROLES = %w(admin confirmed_user)

  delegate :can?, :cannot?, to: :ability

  def ability
    @ability ||= Ability.new(self)
  end

  def guest?
    type == 'Guest'
  end

  def is? role
    role_symbols.include? role
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

  def name
    full_name.present? ? full_name : user_name
  end

  def to_param
    user_name
  end

  protected
    def password_required?
      false
    end
end