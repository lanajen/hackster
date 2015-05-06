class BlogPost < Post
  include Taggable

  validates :slug, presence: true, uniqueness: { scope: :type }, format: { with: /\A[a-zA-Z0-9\-\/]+\z/, message: "only accepts letters, digits and the symbols - and /." }
  attr_accessible :slug, :published_at, :images_attributes, :cover_image_attributes
  before_validation :generate_slug, if: proc{|p| p.slug.blank? }
  before_create :set_threadable

  has_many :blog_tags, as: :taggable, class_name: 'BlogTag'
  has_many :images, as: :attachable, class_name: 'Document'
  has_one :cover_image, as: :attachable

  accepts_nested_attributes_for :images, :cover_image

  taggable :blog_tags

  default_scope do
    order(published_at: :desc)
  end

  self.per_page = 10

  def self.published
    where(private: false).where("threads.published_at < ? OR threads.published_at IS NULL", Time.now)
  end

  def excerpt
    extract_excerpt[0]
  end

  def has_more?
    extract_excerpt[1].present?
  end

  def public?
    super and (published_at.nil? or published_at < Time.now)
  end

  def tags
    blog_tags
  end

  private
    def generate_slug
      return if title.blank?

      self.slug = title.gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase[0..20]
    end

    def generate_sub_id
      self.sub_id = ThreadPost.where(type: type).size + 1
    end

    def set_threadable
      self.threadable_id = 1
      self.threadable_type = 'Hackster'
    end

    def extract_excerpt
      @extract_excerpt ||= body.split('<!-- truncate -->')
    end
end