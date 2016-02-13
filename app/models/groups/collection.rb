class Collection < Group
  include Privatable

  has_many :active_members, -> { where("members.requested_to_join_at IS NULL OR members.approved_to_join = 't'") }, foreign_key: :group_id, class_name: 'ListMember'
  has_many :follow_relations, as: :followable, dependent: :destroy
  has_many :followers, through: :follow_relations, source: :user
  has_many :members, dependent: :destroy, foreign_key: :group_id, class_name: 'ListMember'

  validates :user_name, :new_user_name, :full_name, presence: true
  validate :user_name_is_unique
  before_validation :update_user_name, on: :create

  has_counter :external_projects, 'projects.external.count'
  has_counter :members, 'followers.count', accessor: false
  has_counter :private_projects, 'projects.pryvate.count'
  has_counter :projects, 'projects.publyc.visible.count', accessor: false
  has_counter :team_members, 'team_members.count'

  hstore_column :hproperties, :hashtag, :string, default: "#%{name.gsub(/\s+/, '')}"
  hstore_column :hproperties, :is_new, :boolean, default: false
  hstore_column :hproperties, :mark_new_until, :datetime

  # beginning of search methods
  has_algolia_index 'pryvate'
  def to_indexed_json
    super.merge({
      url: UrlGenerator.new(path_prefix: nil, locale: nil).group_path(self),
    })
  end
  # end of search methods

  def self.default_access_level
    'invite'
  end

  def self.default_permission
    'manage'
  end

  def self.model_name
    Group.model_name
  end

  def followers_count=(val)
    self.members_count = val
  end

  def followers_count
    members_count
  end

  def team_members
    active_members
  end

  def to_tracker
    {
      followers_count: followers_count,
      projects_count: projects_count,
      id: id,
      views_count: impressions_count,
    }
  end

  def update_user_name
    obj = self.class.new full_name: full_name_was
    was_auto_generated = (@old_user_name == obj.generate_user_name)
    new_user_name_changed = (new_user_name != @old_user_name)

    generate_user_name if was_auto_generated or user_name.blank?
    assign_new_user_name if new_user_name.present? and new_user_name_changed
    user_name
  end

  private
    def user_name_is_unique
      raise StandardError, "'user_name_is_unique' needs to be implemented in '#{self.class.name}'"
    end
end