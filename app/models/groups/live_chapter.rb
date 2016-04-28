class LiveChapter < GeographicCommunity
  EVENT_TYPES = %w(meetup hackathon workshop hangout).sort.freeze

  has_many :events, foreign_key: :parent_id, class_name: 'LiveEvent'
  has_many :members, dependent: :destroy, foreign_key: :group_id, class_name: 'LiveChapterMember'
  has_many :pages, as: :threadable

  hstore_column :hproperties, :event_type, :string, default: 'meetup'
  hstore_column :hproperties, :topic, :string

  add_websites :home

  has_counter :events, 'events.publyc.count'

  def self.default_permission roles=nil
    roles ||= []
    roles = [:member] if roles.empty?
    # we expect that there's always exactly one role set
    {
      organizer: 'manage',
      member: 'read',
    }[roles.first.try(:to_sym)]
  end

  def closest_event
    events.publyc.where("groups.start_date > ?", Time.now).order(:start_date).first || events.publyc.where("groups.start_date < ?", Time.now).order(start_date: :desc).first
  end

  def projects
    BaseArticle.joins("INNER JOIN project_collections ON project_collections.project_id = projects.id").joins("INNER JOIN groups ON groups.id = project_collections.collectable_id AND project_collections.collectable_type = 'Group'").where("groups.parent_id = ?", id)
  end
end