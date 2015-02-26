class Hackathon < Community
  has_many :events, foreign_key: :parent_id
  has_many :members, dependent: :destroy, foreign_key: :group_id, class_name: 'HackathonMember'
  has_many :pages, as: :threadable

  attr_accessible :hashtag, :twitter_widget_id, :show_organizers

  store_accessor :properties, :hashtag, :twitter_widget_id, :show_organizers
  set_changes_for_stored_attributes :properties
  parse_as_booleans :properties, :hidden, :show_organizers

  store :counters_cache, accessors: [:events_count]
  parse_as_integers :counters_cache, :events_count, :members_count, :projects_count

  def self.default_permission
    'manage'
  end

  def closest_event
    events.public.where("groups.start_date > ?", Time.now).order(:start_date).first || events.public.where("groups.start_date < ?", Time.now).order(start_date: :desc).first
  end

  def counters
    super.merge({
      events: "events.public.count",
    })
  end

  def projects
    Project.joins("INNER JOIN project_collections ON project_collections.project_id = projects.id").joins("INNER JOIN groups ON groups.id = project_collections.collectable_id AND project_collections.collectable_type = 'Group'").where("groups.parent_id = ?", id)
  end
end