class Project < ActiveRecord::Base
  include Taggable
#  include Workflow

  belongs_to :user
  has_and_belongs_to_many :followers, class_name: 'User', join_table: 'project_followers'
  has_many :access_groups, dependent: :destroy
  has_many :access_group_members, through: :access_groups
  has_many :blog_posts, as: :threadable, dependent: :destroy
  has_many :issues, as: :threadable, dependent: :destroy
  has_many :images, as: :attachable, dependent: :destroy
  has_many :stages, dependent: :destroy
  has_many :team_members, include: :user
  has_many :users, through: :team_members
  has_many :widgets, through: :stages
  has_one :logo, as: :attachable, class_name: 'Avatar'
  has_one :video, as: :recordable, dependent: :destroy

  sanitize_text :description
  attr_accessible :description, :end_date, :name, :start_date, :images_attributes,
    :video_attributes, :current, :logo_attributes, :team_members_attributes,
    :website, :access_groups_attributes
  attr_accessor :current
  accepts_nested_attributes_for :images, :video, :logo, :team_members,
    :access_groups, allow_destroy: true

  validates :name, presence: true
  before_validation :check_if_current
  before_validation :ensure_website_protocol

  taggable :product_tags, :tech_tags

  # privacy settings
  attr_accessible :private, :privacy_rules_attributes
  has_many :privacy_rules, as: :privatable, dependent: :destroy
  accepts_nested_attributes_for :privacy_rules, allow_destroy: true

  def public?
    private == false
  end

  def visible_to? user
    public? or user.has_access_group_permissions? self or user.is_team_member? self
  end

  # levels:
  # - private (cannot be accessed if not part of the collaborators and not found in search)
  # - public_profile (can be found in search but only collaborators can see all the widgets)
  # - public (can be found and fully seen)
  #

  # beginning of search methods
  include Tire::Model::Search
  include Tire::Model::Callbacks
  index_name BONSAI_INDEX_NAME

  tire do
    mapping do
      indexes :id,              index: :not_analyzed
      indexes :name,            analyzer: 'snowball', boost: 100
      indexes :product_tags,    analyzer: 'snowball'
      indexes :tech_tags,       analyzer: 'snowball'
      indexes :description,     analyzer: 'snowball'
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
      description: description,
      product_tags: product_tags_string,
      tech_tags: tech_tags_string,
      text_widgets: Widget.where(type: 'TextWidget').where('widgets.stage_id IN (?)', stages.pluck(:id)).map{ |w| w.content },
      user_name: team_members.map{ |t| t.user.name },
      private: private,
      created_at: created_at,
    }.to_json
  end
  # end of search methods

  def image
    images.first
  end

#  def issues
#    Issue.where(threadable_type: 'Project', threadable_id: id) + Issue.where(threadable_type: 'Widget').where('threadable_id IN (?)', widgets.pluck('widgets.id'))
#  end

  private
    def check_if_current
      self.end_date = nil if current
    end

    def ensure_website_protocol
      return unless website_changed? and website.present?
      self.website = 'http://' + website unless website =~ /^http/
    end
end
