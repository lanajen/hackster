class Event < Community
  belongs_to :hackathon, foreign_key: :parent_id
  has_many :awards, as: :gradable
  has_many :members, dependent: :destroy, foreign_key: :group_id, class_name: 'EventMember'
  has_many :pages, as: :threadable
  has_many :projects, foreign_key: :collection_id

  attr_accessible :awards_attributes

  accepts_nested_attributes_for :awards

  alias_method :short_name, :name

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

  def name
    "#{hackathon.name} - #{super}"
  end
end