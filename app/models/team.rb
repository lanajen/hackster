class Team < Group
  has_many :projects
  before_save :generate_user_name

  def self.default_permission
    'manage'
  end
end