class Project < ActiveRecord::Base
  include Privatable
  include Taggable
#  include Workflow

  belongs_to :user
  has_and_belongs_to_many :followers, class_name: 'User', join_table: 'project_followers'
  has_many :access_groups, dependent: :destroy
  has_many :access_group_members, through: :access_groups
  has_many :blog_posts, as: :threadable, dependent: :destroy
  has_many :issues, as: :threadable, dependent: :destroy
  has_many :images, as: :attachable, dependent: :destroy
  has_many :participant_invites, dependent: :destroy
  has_many :stages, dependent: :destroy
  has_many :team_members, include: :user
  has_many :users, through: :team_members
  has_many :widgets, order: :position
  has_one :logo, as: :attachable, class_name: 'Avatar'
  has_one :video, as: :recordable, dependent: :destroy

  sanitize_text :description
  attr_accessible :description, :end_date, :name, :start_date, :images_attributes,
    :video_attributes, :current, :logo_attributes, :team_members_attributes,
    :website, :access_groups_attributes, :participant_invites_attributes,
    :one_liner, :widgets_attributes, :featured
  attr_accessor :current
  accepts_nested_attributes_for :images, :video, :logo, :team_members,
    :access_groups, :participant_invites, :widgets, allow_destroy: true

  validates :name, presence: true
  before_validation :check_if_current
  before_validation :ensure_website_protocol

  taggable :product_tags, :tech_tags

  self.per_page = 20

  # beginning of search methods
  include Tire::Model::Search
  include Tire::Model::Callbacks
  index_name BONSAI_INDEX_NAME

  tire do
    mapping do
      indexes :id,              index: :not_analyzed
      indexes :name,            analyzer: 'snowball', boost: 100
      indexes :one_liner,       analyzer: 'snowball'
      indexes :product_tags,    analyzer: 'snowball', boost: 50
#      indexes :tech_tags,       analyzer: 'snowball'
#      indexes :description,     analyzer: 'snowball'
      indexes :text_widgets,    analyzer: 'snowball'
      indexes :user_names,      analyzer: 'snowball'
      indexes :private,         analyzer: 'keyword'
      indexes :created_at
    end
  end

  def to_indexed_json
    {
      _id: id,
      name: name,
      model: self.class.name,
      one_liner: one_liner,
#      description: description,
      product_tags: product_tags_string,
#      tech_tags: tech_tags_string,
      text_widgets: Widget.where(type: 'TextWidget').where('widgets.stage_id IN (?)', stages.pluck(:id)).map{ |w| w.content },
      user_name: team_members.map{ |t| t.user.name },
      private: private,
      created_at: created_at,
    }.to_json
  end
  # end of search methods

  def self.featured
    where(featured: true).order('created_at DESC')
  end

  def self.indexable
    where(private: false)
  end

  def all_issues
    (issues + Issue.where(threadable_type: 'Widget').where('threadable_id IN (?)', widgets.pluck('widgets.id'))).sort_by{ |t| t.created_at }
  end

  def image
    images.first
  end

  def to_param
    "#{id}-#{name.gsub(/[^a-zA-Z0-9]/, '-').gsub(/(\-)+$/, '')}"
  end

  def widgets_first_col
    widgets.first_column
  end

  def widgets_second_col
    widgets.second_column
  end

  private
    def check_if_current
      self.end_date = nil if current
    end

    def ensure_website_protocol
      return unless website_changed? and website.present?
      self.website = 'http://' + website unless website =~ /^http/
    end
end
