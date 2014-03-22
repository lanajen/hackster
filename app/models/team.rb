class Team < Group
  has_many :active_members, -> { where("members.requested_to_join_at IS NULL OR members.approved_to_join = 't'") }, foreign_key: :group_id, class_name: 'Member'
  has_many :grades, as: :gradable
  has_many :projects

  validates :user_name, :new_user_name, length: { in: 3..100 }, allow_blank: true, if: proc{|t| t.persisted?}

  before_save :update_user_name

  def self.default_permission
    'manage'
  end

  def generate_user_name exclude_destroyed=true
    cached_members = members
    cached_members = members.reject{|m| m.marked_for_destruction? } if exclude_destroyed
    self.user_name = (cached_members.size == 1 ? cached_members.first.user.user_name : id)
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
    user_name
  end
end