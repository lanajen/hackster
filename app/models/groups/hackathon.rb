class Hackathon < Community
  include TablelessAssociation

  has_many :events, foreign_key: :parent_id
  has_many :members, dependent: :destroy, foreign_key: :group_id, class_name: 'HackathonMember'
  has_many :pages, as: :threadable
  has_many_tableless :schedule_items, order: :position

  store :properties, accessors: []  # left so that tableless schedule_items work

  hstore_column :hproperties, :hashtag, :string
  hstore_column :hproperties, :show_organizers, :boolean
  hstore_column :hproperties, :twitter_widget_id, :string

  has_counter :events, 'events.public.count'

  def self.default_permission
    'manage'
  end

  def closest_event
    events.public.where("groups.start_date > ?", Time.now).order(:start_date).first || events.public.where("groups.start_date < ?", Time.now).order(start_date: :desc).first
  end

  def projects
    BaseArticle.joins("INNER JOIN project_collections ON project_collections.project_id = projects.id").joins("INNER JOIN groups ON groups.id = project_collections.collectable_id AND project_collections.collectable_type = 'Group'").where("groups.parent_id = ?", id)
  end
end