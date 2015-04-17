class Challenge < ActiveRecord::Base
  DEFAULT_DURATION = 60
  VISIBLE_STATES = %w(in_progress ended paused canceled judging judged)

  include Counter
  include StringParser
  include Workflow

  belongs_to :platform
  has_many :admins, through: :challenge_admins, source: :user
  has_many :challenge_admins
  has_many :entries, -> { order(:created_at) }, dependent: :destroy, class_name: ChallengeEntry
  has_many :entrants, through: :projects, source: :users
  has_many :prizes, -> { order(:position) }, dependent: :destroy
  has_many :projects, through: :entries
  has_one :avatar, as: :attachable, dependent: :destroy
  has_one :cover_image, as: :attachable, dependent: :destroy
  validates :name, :slug, presence: true
  validates :teaser, :custom_tweet, length: { maximum: 140 }
  before_validation :assign_new_slug
  before_validation :generate_slug, if: proc{ |c| c.slug.blank? }

  attr_accessible :new_slug, :name, :prizes_attributes, :platform_id, :description,
    :rules, :teaser, :multiple_entries, :duration, :eligibility, :requirements,
    :judging_criteria, :how_to_enter, :video_link, :cover_image_id, :project_ideas,
    :end_date, :end_date_dummy, :avatar_id, :custom_tweet, :sponsor_name,
    :sponsor_link, :custom_css
  attr_accessor :new_slug, :end_date_dummy

  store :properties, accessors: [:description, :rules, :teaser, :multiple_entries,
    :eligibility, :requirements, :judging_criteria, :how_to_enter, :project_ideas,
    :custom_tweet, :sponsor_name, :sponsor_link, :custom_css]

  accepts_nested_attributes_for :prizes, allow_destroy: true

  parse_as_booleans :properties, :multiple_entries, :project_ideas

  store :counters_cache, accessors: [:projects_count]

  parse_as_integers :counters_cache, :projects_count

  is_impressionable counter_cache: true, unique: :session_hash

  workflow do
    state :new do
      event :launch, transitions_to: :in_progress, if: :end_date_is_valid
    end
    state :in_progress do
      event :cancel, transitions_to: :canceled
      event :end, transitions_to: :judging
      event :pause, transitions_to: :paused
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

  def counters
    {
      projects: 'entries.approved.count',
    }
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

  private
    def end_date_is_valid?
      errors.add :end_date_dummy, 'is required' and return unless end_date
      errors.add :end_date_dummy, 'must be at least 5 days in the future' and return if end_date < 5.days.from_now
      true
    end
end
