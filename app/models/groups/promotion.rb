class Promotion < Community
  belongs_to :course, foreign_key: :parent_id
  has_many :assignments, -> { order(:id_for_promotion) }, dependent: :destroy
  has_many :members, dependent: :destroy, foreign_key: :group_id, class_name: 'PromotionMember'

  alias_method :short_name, :name

  attr_accessible :parent_id

  # beginning of search methods
  include Tire::Model::Search
  include Tire::Model::Callbacks
  index_name ELASTIC_SEARCH_INDEX_NAME

  tire do
    mapping do
      indexes :id,              index: :not_analyzed
      indexes :name,            analyzer: 'snowball', boost: 100
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
      private: private,
      created_at: created_at,
    }.to_json
  end
  # end of search methods

  def generate_user_name
    slug = short_name.gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase
    self.user_name = slug
  end

  def name
    "#{course.name} #{super} @#{course.university.name}"
  end

  def proper_name
    course.name
  end

  def professor
    members.with_group_roles(:professor).includes(:user).first
  end

  def projects
    Project.joins(:project_collections).where(project_collections: { collectable_type: 'Assignment', collectable_id: Assignment.where(promotion_id: id) })
  end

  def project_collections
    ProjectCollection.where(project_collections: { collectable_type: 'Assignment', collectable_id: Assignment.where(promotion_id: id) })
  end
end