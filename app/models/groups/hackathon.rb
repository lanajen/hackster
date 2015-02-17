class Hackathon < Community
  has_many :events, foreign_key: :parent_id

  attr_accessible :hashtag, :twitter_widget_id

  store_accessor :properties, :hashtag, :twitter_widget_id
  set_changes_for_stored_attributes :properties

  store_accessor :counters_cache, :events_count
  parse_as_integers :counters_cache, :events_count, :members_count, :projects_count

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