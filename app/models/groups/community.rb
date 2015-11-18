class Community < Group
  include Privatable

  has_many :members, dependent: :destroy, foreign_key: :group_id, class_name: 'CommunityMember'
  validates :user_name, :full_name, presence: true
  validate :user_name_is_unique
  validates :user_name, uniqueness: { scope: [:type, :parent_id] }

  before_validation :generate_user_name, on: :create

  def self.default_access_level
    'request'
  end

  def self.model_name
    Group.model_name
  end

  protected
    def user_name_is_unique
      errors.add :new_user_name, 'has already been taken' if new_user_name.present? and self.class.where(type: type, parent_id: parent_id).where("LOWER(groups.user_name) = ?", new_user_name.downcase).where.not(id: id).any?
    end
end