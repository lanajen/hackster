class ShortLink < ActiveRecord::Base
  is_impressionable counter_cache: true

  validates :slug, length: { maximum: 30 }, format: { with: /\A[a-zA-Z0-9_\-]+\z/, message: "accepts only letters, numbers, underscores '_' and dashes '-'." }, allow_blank: true
  validates :slug, presence: true, if: proc {|s| s.persisted? }
  validates :slug, uniqueness: true, if: proc {|s| s.persisted? and s.slug_changed? }
  validates :redirect_to_url, presence: true
  validate :validate_redirect_to_url
  before_create :generate_slug, if: proc {|s| s.slug.blank? }

  private
    def generate_slug
      slug = SlugGenerator.new(6).to_s

      while ShortLink.where(slug: slug).exists?
        slug = SlugGenerator.new(6).to_s
      end

      self.slug = slug
    end

    def validate_redirect_to_url
      return unless redirect_to_url.present?

      url = Url.new(redirect_to_url)
      errors.add redirect_to_url, 'is not a valid URL' unless url.valid?
      self.redirect_to_url = url.to_s
    end
end