class Challenge < ActiveRecord::Base
  DEFAULT_DURATION = 60
  VISIBLE_STATES = %w(in_progress ended paused canceled judging judged)

  include StringParser
  include Workflow

  belongs_to :platform, foreign_key: :tech_id
  has_many :admins, through: :challenge_admins, source: :user
  has_many :challenge_admins
  has_many :entries, -> { order(:created_at) }, dependent: :destroy, class_name: ChallengeEntry
  has_many :entrants, through: :projects, source: :users
  has_many :prizes, -> { order(:position) }, dependent: :destroy
  has_many :projects, through: :entries
  has_one :cover_image, as: :attachable, class_name: 'Document', dependent: :destroy
  has_one :tile_image, as: :attachable, class_name: 'Image', dependent: :destroy
  validates :name, :slug, presence: true
  validates :teaser, length: { maximum: 140 }
  before_validation :assign_new_slug
  before_validation :generate_slug, if: proc{ |c| c.slug.blank? }

  attr_accessible :new_slug, :name, :prizes_attributes, :tech_id, :description,
    :rules, :teaser, :multiple_entries, :duration, :eligibility, :requirements,
    :judging_criteria, :how_to_enter, :video_link, :cover_image_id, :project_ideas
  attr_accessor :new_slug

  store :properties, accessors: [:description, :rules, :teaser, :multiple_entries,
    :eligibility, :requirements, :judging_criteria, :how_to_enter, :project_ideas]

  accepts_nested_attributes_for :prizes, allow_destroy: true

  parse_as_booleans :properties, :multiple_entries

  workflow do
    state :new do
      event :launch, transitions_to: :in_progress
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

  def cover_image_id=(val)
    self.cover_image = Document.find_by_id(val)
  end

  def duration
    @duration ||= read_attribute(:duration) || DEFAULT_DURATION
  end

  def end
    notify_observers(:after_end)
  end

  def end_date
    return unless start_date.present?

    start_date + duration.days
  end

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
end
