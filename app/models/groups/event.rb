class Event < GeographicCommunity
  include HasDefault
  include TablelessAssociation

  CTA_TEXT = ['Buy your ticket', 'RSVP now']

  belongs_to :hackathon, foreign_key: :parent_id
  has_many :awards, -> { order(user_id: :asc) }, as: :gradable  # user_id is reused as "position"
  has_many :members, dependent: :destroy, foreign_key: :group_id, class_name: 'EventMember'
  has_many :pages, as: :threadable
  has_many_tableless :schedule_items, order: :position

  attr_accessor :start_date_dummy, :end_date_dummy, :voting_end_date_dummy

  attr_accessible :awards_attributes, :parent_id,
    :start_date_dummy, :end_date_dummy,
    :voting_end_date_dummy, :start_date, :end_date

  accepts_nested_attributes_for :awards, allow_destroy: true

  add_websites :tickets

  store :properties, accessors: []  # left so that tableless schedule_items work

  hstore_column :hproperties, :activate_voting, :boolean
  hstore_column :hproperties, :cta_text, :string, default: CTA_TEXT.first
  hstore_column :hproperties, :schedule, :string
  hstore_column :hproperties, :voting_end_date, :datetime
  hstore_column :hproperties, :voting_start_date, :datetime

  has_counter :participants, "members.joins(:user).request_accepted_or_not_requested.invitation_accepted_or_not_invited.with_group_roles('participant').count"

  alias_method :short_name, :name

  %w(facebook twitter linked_in google_plus github blog website youtube pinterest flickr instagram reddit).each do |link|
    define_method "#{link}_link" do
      websites["#{link}_link"].presence || hackathon.try("#{link}_link")
    end
  end

  has_algolia_index 'pryvate'

  def self.now
    where("groups.start_date < ? AND groups.end_date > ?", Time.now, Time.now).order(start_date: :asc, end_date: :desc)
  end

  def self.upcoming
    where("groups.start_date > ?", Time.now).order(start_date: :asc)
  end

  def self.past
    where("groups.end_date < ?", Time.now).order(start_date: :desc)
  end

  def self.recent
    where("groups.start_date < ? AND groups.end_date > ?", 7.days.from_now, 7.days.ago).order(start_date: :asc, end_date: :desc)
  end

  def avatar
    hackathon.try(:avatar)
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

  def in_the_future?
    start_date and start_date > Time.now
  end

  def mini_resume
    super.presence || hackathon.try(:mini_resume)
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

  def voting_end_date_dummy
    voting_end_date ? voting_end_date.strftime("%m/%d/%Y %l:%M %P") : Time.now.strftime("%m/%d/%Y %l:%M %P")
  end

  def voting_active?
    activate_voting and voting_end_date and voting_end_date > Time.now
  end
end