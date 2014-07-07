class Team < Group
  has_many :grades, as: :gradable
  has_many :projects

  validates :user_name, :new_user_name, length: { in: 3..100 }, allow_blank: true, if: proc{|t| t.persisted?}
  validates :prevent_save, absence: true

  attr_accessor :prevent_save

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
    self.user_name = if full_name.present?
      super()
    else
      (cached_members.size == 1 ? cached_members.first.user.user_name : id.to_s)
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
    was_auto_generated = if members.find_index{|m| m.new_record? || m.marked_for_destruction?}
      team = Team.new
      team.prevent_save = true  # otherwise this new group gets saved and the old members assigned to it
      team.members = members.reject{|m| m.new_record?}
      user_name == team.generate_user_name(false)
    end
    new_user_name_changed = (new_user_name != user_name)

    generate_user_name if user_name.blank? or was_auto_generated or full_name_changed?
    assign_new_user_name if new_user_name_changed
    user_name
  end
end