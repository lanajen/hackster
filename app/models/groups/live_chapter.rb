class LiveChapter < GeographicCommunity
  EVENT_TYPES = %w(meetup hackathon workshop hangout).sort.freeze

  has_many :members, dependent: :destroy, foreign_key: :group_id, class_name: 'LiveChapterMember'

  hstore_column :hproperties, :event_type, :string, default: 'meetup'
  add_websites :home

  validates :home_link, presence: true

  def self.default_permission roles=nil
    roles ||= []
    roles = [:member] if roles.empty?
    # we expect that there's always exactly one role set
    {
      organizer: 'manage',
      member: 'read',
    }[roles.first.try(:to_sym)]
  end
end