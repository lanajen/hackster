class Challenge < ActiveRecord::Base
  DEFAULT_DURATION = 60
  VISIBLE_STATES = %w(in_progress ended paused canceled judging judged)
  VOTING_START_OPTIONS = {
    'Now' => :now,
    'When the challenge ends' => :end,
  }

  include HstoreColumn
  include HstoreCounter
  include Workflow

  belongs_to :platform
  has_many :admins, through: :challenge_admins, source: :user
  has_many :challenge_admins
  has_many :entries, class_name: 'ChallengeEntry', dependent: :destroy
  has_many :entrants, through: :projects, source: :users
  has_many :prizes, -> { order(:position) }, dependent: :destroy
  # see https://github.com/rails/rails/issues/19042#issuecomment-91405982 about
  # "counter_cache: :this_is_not_a_column_that_exists"
  has_many :projects, -> { order('challenge_projects.created_at ASC') },
    through: :entries, counter_cache: :this_is_not_a_column_that_exists
  has_many :votes, through: :entries
  has_one :avatar, as: :attachable, dependent: :destroy
  has_one :cover_image, as: :attachable, dependent: :destroy
  validates :name, :slug, presence: true
  validates :teaser, :custom_tweet, length: { maximum: 140 }
  validate :password_exists
  before_validation :assign_new_slug
  before_validation :generate_slug, if: proc{ |c| c.slug.blank? }

  attr_accessible :new_slug, :name, :prizes_attributes, :platform_id, :duration,
    :video_link, :cover_image_id, :end_date, :end_date_dummy, :avatar_id,
    :challenge_admins_attributes, :voting_end_date_dummy
  attr_accessor :new_slug, :end_date_dummy, :voting_end_date_dummy

  accepts_nested_attributes_for :prizes, :challenge_admins, allow_destroy: true

  store :properties, accessors: []
  hstore_column :hproperties, :activate_banners, :boolean, default: true
  hstore_column :hproperties, :activate_voting, :boolean
  hstore_column :hproperties, :allow_anonymous_votes, :boolean
  hstore_column :hproperties, :custom_css, :string
  hstore_column :hproperties, :custom_tweet, :string
  hstore_column :hproperties, :description, :string
  hstore_column :hproperties, :eligibility, :string
  hstore_column :hproperties, :how_to_enter, :string
  hstore_column :hproperties, :judging_criteria, :string
  hstore_column :hproperties, :multiple_entries, :boolean
  hstore_column :hproperties, :password_protect, :boolean
  hstore_column :hproperties, :password, :string
  hstore_column :hproperties, :project_ideas, :boolean
  hstore_column :hproperties, :requirements, :string
  hstore_column :hproperties, :rules, :string
  hstore_column :hproperties, :teaser, :string
  hstore_column :hproperties, :sponsor_link, :string
  hstore_column :hproperties, :sponsor_name, :string
  hstore_column :hproperties, :voting_start, :string, default: :end
  hstore_column :hproperties, :voting_end_date, :datetime, default: proc{|c| c.end_date ? c.end_date + 7.days : nil }

  counters_column :hcounters_cache
  has_counter :projects, 'entries.approved.count'

  is_impressionable counter_cache: true, unique: :session_hash

  workflow do
    state :new do
      event :launch, transitions_to: :in_progress, if: :end_date_is_valid
    end
    state :in_progress do
      event :cancel, transitions_to: :canceled
      event :end, transitions_to: :judging
      event :pause, transitions_to: :paused
      event :take_offline, transitions_to: :new
    end
    state :canceled
    state :paused do
      event :restart, transitions_to: :in_progress
    end
    state :judging do
      event :mark_as_judged, transitions_to: :judged
    end
    state :judged
  end

  def self.active
    where(workflow_state: :in_progress)
  end

  def self.public
    where "CAST(hproperties -> 'password_protect' AS BOOLEAN) = ?", false
  end

  def allow_multiple_entries?
    multiple_entries
  end

  def auto_approve?
    true
  end

  def assign_new_slug
    @old_slug = slug
    self.slug = new_slug
  end

  def avatar_id=(val)
    self.avatar = Avatar.find_by_id(val)
  end

  def cover_image_id=(val)
    self.cover_image = CoverImage.find_by_id(val)
  end

  def display_banners?
    platform and activate_banners and !password_protect?
  end

  def duration
    @duration ||= read_attribute(:duration) || DEFAULT_DURATION
  end

  def end
    notify_observers(:after_end)
  end

  def ended?
    end_date and Time.now > end_date
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

  # def end_date
  #   return unless start_date.present?

  #   start_date + duration.days
  # end

  def generate_slug
    return if name.blank?

    slug = name.gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase

    # make sure it doesn't exist
    if result = self.class.where(slug: slug).first
      return if self == result
      # if it exists add a 1 and increment it if necessary
      slug += '1'
      while self.class.where(slug: slug).first
        slug.gsub!(/([0-9]+$)/, ($1.to_i + 1).to_s)
      end
    end
    self.slug = slug
  end

  def launch
    halt and return unless end_date_is_valid?

    self.start_date = Time.now
    save
    notify_observers(:after_launch)
  end

  def locked? session
    password_protect? and session[:challenge_keys].try(:[], id) != Digest::SHA1.hexdigest(password)
  end

  def mark_as_judged
    notify_observers(:after_judging)
  end

  def new_slug
    # raise new_slug.to_s
    @new_slug ||= slug
  end

  def open_for_submissions?
    in_progress?
  end

  def ready_for_judging?
    judging?
  end

  def unlock try_password
    Digest::SHA1.hexdigest(password) if password.present? and password == try_password
  end

  def video
    return unless video_link.present?

    @video ||= Embed.new url: video_link
  end

  def voting_end_date_dummy
    voting_end_date ? voting_end_date.strftime("%m/%d/%Y %l:%M %P") : Time.now.strftime("%m/%d/%Y %l:%M %P")
  end

  def voting_active?
    activate_voting and (voting_start == :now or end_date and end_date < Time.now) and voting_end_date and voting_end_date > Time.now
  end

  private
    def end_date_is_valid?
      errors.add :end_date_dummy, 'is required' and return unless end_date
      errors.add :end_date_dummy, 'must be at least 5 days in the future' and return if end_date < 5.days.from_now
      true
    end

    def password_exists
      errors.add :password, 'is required when password protection is enabled' if password_protect? and password.blank?
    end
end
