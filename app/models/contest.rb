class Contest < ActiveRecord::Base
  DEFAULT_DURATION = 60
  VISIBLE_STATES = %w(in_progress ended paused canceled)

  include StringParser
  include Workflow

  belongs_to :tech
  has_many :contest_projects, dependent: :destroy
  has_many :entrants, through: :projects, source: :users
  has_many :prizes, -> { order(:position) }, dependent: :destroy
  has_many :projects, through: :contest_projects
  has_one :cover_image, as: :attachable, class_name: 'CoverImage', dependent: :destroy
  has_one :tile_image, as: :attachable, class_name: 'Image', dependent: :destroy
  validates :name, :slug, presence: true
  validates :teaser, length: { maximum: 140 }
  before_validation :assign_new_slug
  before_validation :generate_slug, if: proc{ |c| c.slug.blank? }

  attr_accessible :new_slug, :name, :prizes_attributes, :tech_id, :description,
    :rules, :teaser, :multiple_entries, :duration, :eligibility, :requirements,
    :judging_criteria, :how_to_enter, :video_link
  attr_accessor :new_slug

  store :properties, accessors: [:description, :rules, :teaser, :multiple_entries,
    :eligibility, :requirements, :judging_criteria, :how_to_enter]

  accepts_nested_attributes_for :prizes, allow_destroy: true

  parse_as_booleans :properties, :multiple_entries

  workflow do
    state :new do
      event :launch, transitions_to: :in_progress
    end
    state :in_progress do
      event :cancel, transitions_to: :canceled
      event :end, transitions_to: :ended
      event :pause, transitions_to: :paused
    end
    state :canceled
    state :ended
    state :paused do
      event :restart, transitions_to: :in_progress
    end
  end

  def allow_multiple_entries?
    multiple_entries
  end

  def assign_new_slug
    @old_slug = slug
    self.slug = new_slug
  end

  def duration
    @duration ||= DEFAULT_DURATION
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
  end

  def new_slug
    # raise new_slug.to_s
    @new_slug ||= slug
  end

  def open_for_submissions?
    in_progress?
  end
end
