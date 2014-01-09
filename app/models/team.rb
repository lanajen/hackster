class Team < Group
  has_many :projects
  before_save :update_user_name

  attr_writer :new_user_name
  attr_accessible :new_user_name

  validates :new_user_name, exclusion: { in: %w(projects terms privacy admin infringement_policy search users) }
  validates :new_user_name, length: { in: 3..100 }, presence: true, if: proc{|t| t.persisted?}

  def self.default_permission
    'manage'
  end

  def assign_new_user_name
    self.user_name = new_user_name
  end

  def new_user_name
    @new_user_name ||= user_name
  end

  # How user_name generation works: a new user_name is generated automatically
  # only when the old user_name was also automatically generated. A manually
  # entered user_name (new_user_name) is used only when the input version is
  # different from the old user_name. If both conditions are false then the old
  # user_name is kept.
  def update_user_name
    was_auto_generated = if members.find_index{|m| m.new_record? || m.marked_for_destruction?}
      group = Group.new
      group.members = members.reject{|m| m.new_record?}
      user_name == group.generate_user_name(false)
    end
    new_user_name_changed = (new_user_name != user_name)

    generate_user_name if was_auto_generated or user_name.blank?
    assign_new_user_name if new_user_name_changed
  end
end