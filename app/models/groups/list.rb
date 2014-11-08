class List < Group
  include Counter
  include Privatable
  include StringParser
  include Taggable

  has_many :active_members, -> { where("members.requested_to_join_at IS NULL OR members.approved_to_join = 't'") }, foreign_key: :group_id, class_name: 'ListMember'
  has_many :follow_relations, as: :followable
  has_many :followers, through: :follow_relations, source: :user
  has_many :members, dependent: :destroy, foreign_key: :group_id, class_name: 'ListMember'
  has_one :cover_image, as: :attachable, class_name: 'Document', dependent: :destroy

  attr_accessible :cover_image_id

  validates :user_name, :full_name, presence: true
  validate :user_name_is_unique
  # before_save :update_user_name

  store :counters_cache, accessors: [:projects_count, :followers_count,
    :external_projects_count, :private_projects_count]

  parse_as_integers :counters_cache, :projects_count, :followers_count,
    :external_projects_count, :private_projects_count

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

  def counters
    {
      external_projects: 'projects.external.count',
      followers: 'followers.count',
      private_projects: 'projects.private.count',
      projects: 'projects.visible.indexable_and_external.count',
    }
  end

  def cover_image_id=(val)
    self.cover_image = Document.find_by_id(val)
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
    # raise "#{new_user_name}|#{user_name}|#{@old_user_name}"
    obj = self.class.new full_name: full_name_was
    was_auto_generated = (@old_user_name == obj.generate_user_name)
    new_user_name_changed = (new_user_name != @old_user_name)

    generate_user_name if was_auto_generated or user_name.blank?
    assign_new_user_name if new_user_name_changed
  end

  private
    def user_name_is_unique
      return unless new_user_name.present?

      list = List.where("LOWER(groups.user_name) = ?", new_user_name.downcase).where(type: 'List').where.not(id: id).first
      errors.add :new_user_name, 'is already taken' if list
    end
end