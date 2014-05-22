class Tech < Group
  include Privatable
  include Taggable

  has_many :members, dependent: :destroy, foreign_key: :group_id, class_name: 'TechMember'
  has_many :respects, as: :respecting, dependent: :destroy, class_name: 'Respect'
  has_many :respected_projects, through: :respects, source: :project
  has_one :cover_image, as: :attachable, class_name: 'Logo', dependent: :destroy
  has_one :logo, as: :attachable, dependent: :destroy
  has_one :slug, as: :sluggable, dependent: :destroy, class_name: 'SlugHistory'

  store :websites, accessors: [:facebook_link, :twitter_link, :linked_in_link,
    :google_plus_link, :youtube_link, :website_link, :blog_link, :github_link,
    :forums_link, :documentation_link, :crowdfunding_link, :buy_link,
    :shoplocket_link]

  attr_accessible :forums_link, :documentation_link, :crowdfunding_link,
    :buy_link, :logo_id, :shoplocket_link, :cover_image_id

  validates :user_name, :full_name, presence: true
  validates :user_name, :new_user_name, length: { in: 3..100 }, if: proc{|t| t.persisted?}
  validate :user_name_is_unique
  before_validation :update_user_name

  taggable :tech_tags

  # beginning of search methods
  include Tire::Model::Search
  include Tire::Model::Callbacks
  index_name ELASTIC_SEARCH_INDEX_NAME

  tire do
    mapping do
      indexes :id,              index: :not_analyzed
      indexes :name,            analyzer: 'snowball', boost: 200
      indexes :tech_tags,       analyzer: 'snowball', boost: 150
      indexes :mini_resume,     analyzer: 'snowball'
      indexes :private,         analyzer: 'keyword'
      indexes :created_at
    end
  end

  def to_indexed_json
    {
      _id: id,
      name: name,
      model: self.class.name,
      mini_resume: mini_resume,
      tech_tags: tech_tags_string,
      private: private,
      created_at: created_at,
    }.to_json
  end
  # end of search methods

  def self.model_name
    Group.model_name
  end

  def cover_image_id=(val)
    self.cover_image = CoverImage.find_by_id(val)
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

  def projects
    # Project.includes(:tech_tags).where(tags: { name: tech_tags.pluck(:name) })
    Project.includes(:tech_tags).where('lower(tags.name) IN (?)', tech_tags.pluck(:name).map{|n| n.downcase })
    # SearchRepository.new(q: tech_tags_string).search.results
  end

  def shoplocket_token
    return unless shoplocket_link.present?

    shoplocket_link.split(/\//)[-1]
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