class LiveChapter < ActiveRecord::Base
  EVENT_TYPES = %w(meetup hackathon workshop hangout).sort.freeze

  belongs_to :organizer, class_name: 'User'
  has_one :cover_image, as: :attachable

  attr_accessible :cover_image_id, :name, :event_type, :link, :organizer_id,
    :city, :country, :virtual, :one_liner

  validates :link, :organizer, presence: true
  validates :one_liner, length: { maximum: 140 }
  validate :validate_link

  def cover_image_id=(val)
    self.cover_image = CoverImage.find_by_id val
  end

  private
    def validate_link
      errors.add :link, 'is not a valid URL' unless Url.new(link).valid?
    end
end
