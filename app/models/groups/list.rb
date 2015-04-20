class List < Group
  include Privatable
  include StringParser

  has_many :active_members, -> { where("members.requested_to_join_at IS NULL OR members.approved_to_join = 't'") }, foreign_key: :group_id, class_name: 'ListMember'
  has_many :follow_relations, as: :followable
  has_many :followers, through: :follow_relations, source: :user
  has_many :members, dependent: :destroy, foreign_key: :group_id, class_name: 'ListMember'

  attr_accessible :list_type, :is_new, :enable_comments, :hashtag

  validates :user_name, :full_name, presence: true
  validate :user_name_is_unique
  before_validation :update_user_name, on: :create

  store :counters_cache, accessors: [:external_projects_count,
    :private_projects_count]

  parse_as_integers :counters_cache, :external_projects_count,
    :private_projects_count

  store_accessor :properties, :list_type, :is_new, :enable_comments, :hashtag
  set_changes_for_stored_attributes :properties

  parse_as_booleans :properties, :is_new, :enable_comments, :hidden

  # beginning of search methods
  tire do
    mapping do
      indexes :id,              index: :not_analyzed
      indexes :name,            analyzer: 'snowball', boost: 1000
      indexes :mini_resume,     analyzer: 'snowball', boost: 100
      indexes :created_at
    end
  end

  def to_indexed_json
    {
      _id: id,
      name: name,
      model: self.class.name.underscore,
      mini_resume: mini_resume,
      created_at: created_at,
      popularity: 1000.0,
    }.to_json
  end

  def self.index_all
    index.import public
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

  def category?
    list_type == 'category'
  end

  def counters
    {
      external_projects: 'projects.external.count',
      members: 'followers.count',
      private_projects: 'projects.private.count',
      products: 'projects.products.count',
      projects: 'project_collections.visible.count',
    }
  end

  def default_hashtag
    "##{name.gsub(/\s+/, '')}"
  end

  def followers_count=(val)
    self.members_count = val
  end

  def followers_count
    members_count
  end

  def to_tracker
    {
      followers_count: followers_count,
      projects_count: projects_count,
      list_id: id,
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
      return unless new_user_name.present?

      list = List.where("LOWER(groups.user_name) = ?", new_user_name.downcase).where(type: 'List').where.not(id: id).first
      errors.add :new_user_name, 'is already taken' if list
    end
end