class Tech < Group
  PROJECT_IDEAS_PHRASING = ['"No #{name} yet?"', '"Have ideas on what to build with #{name}?"']
  include Counter
  include Privatable
  include StringParser
  include Taggable

  has_many :active_members, -> { where("members.requested_to_join_at IS NULL OR members.approved_to_join = 't'") }, foreign_key: :group_id, class_name: 'TechMember'
  has_many :announcements, as: :threadable, dependent: :destroy
  has_many :featured_projects, -> { where("group_relations.workflow_state = 'featured'") }, source: :project, through: :group_relations
  has_many :follow_relations, as: :followable
  has_many :followers, through: :follow_relations, source: :user
  has_many :members, dependent: :destroy, foreign_key: :group_id, class_name: 'TechMember'
  has_one :cover_image, as: :attachable, class_name: 'Document', dependent: :destroy
  has_one :logo, as: :attachable, dependent: :destroy
  has_one :slug, as: :sluggable, dependent: :destroy, class_name: 'SlugHistory'


  attr_accessible :forums_link, :documentation_link, :crowdfunding_link,
    :buy_link, :logo_id, :shoplocket_link, :cover_image_id, :accept_project_ideas,
    :project_ideas_phrasing

  validates :user_name, :full_name, presence: true
  validates :user_name, :new_user_name, length: { in: 3..100 }, if: proc{|t| t.persisted?}
  validate :user_name_is_unique
  before_validation :update_user_name

  store_accessor :websites, :forums_link, :documentation_link, :crowdfunding_link, :buy_link,
    :shoplocket_link
  set_changes_for_stored_attributes :websites
  store :properties, accessors: [:accept_project_ideas, :project_ideas_phrasing]
  store :counters_cache, accessors: [:projects_count, :followers_count,
    :external_projects_count, :private_projects_count]
  set_changes_for_stored_attributes :properties

  parse_as_integers :counters_cache, :projects_count, :followers_count,
    :external_projects_count, :private_projects_count

  parse_as_booleans :properties, :accept_project_ideas

  taggable :tech_tags

  # beginning of search methods
  include Tire::Model::Search
  # include Tire::Model::Callbacks
  index_name ELASTIC_SEARCH_INDEX_NAME

  after_save do
    if private
      IndexerQueue.perform_async :remove, self.class.name, self.id
    else
      IndexerQueue.perform_async :store, self.class.name, self.id
    end
  end
  after_destroy do
    # tricky to move to background; by the time it's processed the model might not exist
    self.index.remove self
  end

  tire do
    mapping do
      indexes :id,              index: :not_analyzed
      indexes :name,            analyzer: 'snowball', boost: 1000
      indexes :tech_tags,       analyzer: 'snowball', boost: 500
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
      tech_tags: tech_tags_string,
      created_at: created_at,
      popularity: 1000.0,
    }.to_json
  end

  def self.for_thumb_display
    includes(:avatar)
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

  def generate_user_name
    return if full_name.blank?

    slug = name.gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase

    # make sure it doesn't exist
    if result = SlugHistory.where(value: slug).first
      return if self == result
      # if it exists add a 1 and increment it if necessary
      slug += '1'
      while SlugHistory.where(value: slug).first
        slug.succ!
      end
    end
    self.user_name = slug
  end

  def logo_id=(val)
    self.logo = Logo.find_by_id(val)
  end

  def project_ideas_phrasing
    super || project_ideas_phrasing_options[0]
  end

  def project_ideas_phrasing_options
    PROJECT_IDEAS_PHRASING.map{|t| eval(t) }
  end

  # def projects
  #   # Project.includes(:tech_tags).where(tags: { name: tech_tags.pluck(:name) })
  #   Project.public.includes(:tech_tags).references(:tags).where('lower(tags.name) IN (?)', tech_tags.pluck(:name).map{|n| n.downcase })
  #   # SearchRepository.new(q: tech_tags_string).search.results
  # end

  def shoplocket_token
    return unless shoplocket_link.present?

    shoplocket_link.split(/\//)[-1]
  end

  def to_tracker
    {
      followers_count: followers_count,
      projects_count: projects_count,
      tech_id: id,
      views_count: impressions_count,
    }
  end

  def update_user_name
    # raise "#{new_user_name}|#{user_name}|#{@old_user_name}"
    tech = Tech.new full_name: full_name_was
    was_auto_generated = (@old_user_name == tech.generate_user_name)
    new_user_name_changed = (new_user_name != @old_user_name)

    generate_user_name if was_auto_generated or user_name.blank?
    assign_new_user_name if new_user_name_changed
  end

  private
    def user_name_is_unique
      return unless new_user_name.present?

      slug = SlugHistory.where(value: new_user_name).first
      errors.add :new_user_name, 'is already taken' if slug and slug.sluggable != self
    end
end