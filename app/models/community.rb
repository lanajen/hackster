class Community < Group
  include Privatable

  has_many :projects, through: :granted_permissions, source: :permissible,
    source_type: 'Project'
  validates :user_name, :full_name, presence: true
  validates :user_name, uniqueness: { scope: [:type, :parent_id] }
  validates :user_name, :new_user_name, length: { in: 3..100 }, if: proc{|t| t.persisted?}
  before_validation :generate_user_name, on: :create

  def self.default_access_level
    'request'
  end

  def self.model_name
    Group.model_name
  end
end