class LiveEventSet < ActiveRecord::Base
  EVENT_TYPES = %w(meetup hackathon workshop hangout).sort.freeze

  belongs_to :organizer, class_name: 'User'

  validates :link, :organizer, presence: true
  validate :validate_link

  private
    def validate_link
      errors.add :link, 'is not a valid URL' unless Url.new(link).valid?
    end
end
