class MeetupEvent < GeographicCommunity
  include HasDefault

  belongs_to :meetup, foreign_key: :parent_id, class_name: 'Group'
  has_many :members, dependent: :destroy, foreign_key: :group_id, class_name: 'EventMember'
  has_many :pages, as: :threadable

  attr_accessor :start_date_dummy, :end_date_dummy

  attr_accessible :parent_id,
    :start_date_dummy, :end_date_dummy,
    :start_date, :end_date

  validates :meetup, :name, :start_date, :end_date, :address, :city, :country,
    :start_date_dummy, :end_date_dummy, presence: true

  hstore_column :hproperties, :about, :string

  add_websites :website

  has_counter :participants, "members.joins(:user).request_accepted_or_not_requested.invitation_accepted_or_not_invited.with_group_roles('participant').count"

  has_algolia_index 'pryvate'

  def self.default_access_level
    'anyone'
  end

  def self.now
    where("groups.start_date < ? AND groups.end_date > ?", Time.now, Time.now).order(start_date: :asc, end_date: :desc)
  end

  def self.past
    where("groups.end_date < ?", Time.now).order(start_date: :desc)
  end

  def self.recent
    where("groups.start_date < ? AND groups.end_date > ?", 7.days.from_now, 7.days.ago).order(start_date: :asc, end_date: :desc)
  end

  def self.upcoming
    where("groups.start_date > ?", Time.now).order(start_date: :asc)
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