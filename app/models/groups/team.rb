class Team < Group
  has_many :grades, as: :gradable
  has_many :projects

  store_accessor :properties, :generated_user_name, :disable_team_append

  parse_as_booleans :properties, :hidden, :disable_team_append

  attr_accessible :disable_team_append

  hstore_column :hproperties, :disable_team_append, :boolean
  hstore_column :hproperties, :generated_user_name, :string

  before_save :update_user_name

  def self.default_access_level
    'request'
  end

  def self.default_permission
    'manage'
  end

  def generate_user_name exclude_destroyed=true
    cached_members = members
    cached_members = members.reject{|m| m.marked_for_destruction? } if exclude_destroyed
    self.generated_user_name = if full_name.present?
      super()
    else
      (cached_members.size == 1 ? cached_members.first.user.user_name : id.to_s)
    end
  end

  def name
    if full_name.present?
      if full_name =~ /team/i or disable_team_append
        full_name
      else
        "Team #{full_name}"
      end
    end
  end

  def project
    projects.first
  end

  # How user_name generation works: a new user_name is generated automatically
  # only when the old user_name was also automatically generated. A manually
  # entered user_name (new_user_name) is used only when the input version is
  # different from the old user_name. If both conditions are false then the old
  # user_name is kept.
  def update_user_name
    was_auto_generated = user_name == generated_user_name

    self.user_name = generate_user_name if user_name.blank? or was_auto_generated or full_name_changed?
    assign_new_user_name if new_user_name_changed? and new_user_name.present?
    user_name
  end
end