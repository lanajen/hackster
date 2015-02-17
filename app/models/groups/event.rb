class Event < GeographicCommunity
  belongs_to :hackathon, foreign_key: :parent_id
  has_many :awards, as: :gradable
  has_many :members, dependent: :destroy, foreign_key: :group_id, class_name: 'EventMember'
  has_many :pages, as: :threadable

  attr_accessor :start_date_dummy, :end_date_dummy

  attr_accessible :awards_attributes, :parent_id, :start_date,
    :start_date_dummy, :end_date, :end_date_dummy

  accepts_nested_attributes_for :awards, allow_destroy: true

  store :counters_cache, accessors: [:participants_count]

  parse_as_integers :counters_cache, :participants_count

  # store_accessor :properties, :start_date, :end_date

  # parse_as_datetimes :properties, :start_date, :end_date

  alias_method :short_name, :name

  # beginning of search methods
  tire do
    mapping do
      indexes :id,              index: :not_analyzed
      indexes :name,            analyzer: 'snowball', boost: 100
      indexes :mini_resume,     analyzer: 'snowball'
      indexes :private,         analyzer: 'keyword'
      indexes :created_at
    end
  end

  %w(facebook twitter linked_in google_plus github blog website youtube).each do |link|
    define_method "#{link}_link" do
      websites["#{link}_link"].presence || hackathon.try("#{link}_link")
    end
  end

  def avatar
    hackathon.try(:avatar)
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

  def counters
    super.merge({
      participants: "members.joins(:user).request_accepted_or_not_requested.invitation_accepted_or_not_invited.with_group_roles('participant').count",
    })
  end

  def default_user_name
    secondary_name.gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase
  end

  def end_date=(val)
    begin
      date = val.to_datetime
      write_attribute :end_date, date
    rescue
    end
  end

  def end_date_dummy
    end_date.strftime("%m/%d/%Y %l:%M %P") if end_date
  end

  # def name
  #   hackathon.name
  # end

  def mini_resume
    hackathon.try(:mini_resume)
  end

  def name
    "#{hackathon.name} - #{super}"
  end

  def proper_name
    hackathon.name
  end

  def secondary_name
    full_name
  end

  def start_date=(val)
    begin
      date = val.to_datetime
      write_attribute :start_date, date
    rescue
    end
  end

  def start_date_dummy
    start_date.strftime("%m/%d/%Y %l:%M %P") if start_date
  end
end