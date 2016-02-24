# - use elastic for search
# - clean up parts/consolidate
# - later: search by part

class Part < ActiveRecord::Base
  DEFAULT_SORT = 'alpha'
  EDITABLE_STATES = %w(new pending_review)
  KNOWN_TYPES = {
    'hardware' => 'component',
    'software' => 'app',
    'tool' => 'tool',
  }
  INVALID_STATES = %w(rejected retired)
  SORTING = {
    'alpha' => :sorted_by_full_name,
    'owned' => :most_followed,
    'used' => :most_used,
  }
  TYPES = %w(Hardware Software Tool).inject({}){|mem, t| mem[t] = "#{t}Part"; mem }
  include HstoreCounter
  include Privatable
  include Taggable
  include WebsitesColumn
  include Workflow

  belongs_to :platform
  has_and_belongs_to_many :parent_parts, join_table: :part_relations, foreign_key: :child_part_id, association_foreign_key: :parent_part_id, class_name: 'Part'
  has_and_belongs_to_many :child_parts, join_table: :part_relations, foreign_key: :parent_part_id, association_foreign_key: :child_part_id, class_name: 'Part'
  has_many :child_platforms, through: :child_parts, source: :platform
  has_many :child_part_relations, foreign_key: :parent_part_id, class_name: 'PartRelation'
  has_many :follow_relations, as: :followable
  has_many :impressions, dependent: :destroy, class_name: 'PartImpression'
  has_many :owners, through: :follow_relations, class_name: 'User', source: :user
  has_many :parent_part_joins, dependent: :destroy, class_name: 'PartJoin', through: :parent_parts, source: :part_joins
  has_many :parent_part_relations, foreign_key: :child_part_id, class_name: 'PartRelation'
  has_many :parent_projects, through: :sub_part_joins, source_type: 'BaseArticle', source: :partable
  has_many :part_joins, inverse_of: :part, dependent: :destroy
  has_many :projects, through: :part_joins, source_type: 'BaseArticle', source: :partable
  has_one :image, as: :attachable, dependent: :destroy

  taggable :product_tags

  attr_accessor :should_generate_slug
  attr_accessible :name, :vendor_link, :vendor_name, :vendor_sku, :mpn, :unit_price,
    :description, :image_id, :platform_id, :part_joins_attributes,
    :part_join_ids, :workflow_state, :slug, :one_liner, :position,
    :child_part_relations_attributes, :parent_part_relations_attributes, :type,
    :link, :image_url, :tags, :should_generate_slug, :generic

  accepts_nested_attributes_for :part_joins, :child_part_relations,
    :parent_part_relations, allow_destroy: true

  has_websites :websites, :store, :documentation, :libraries, :datasheet,
    :product_page, :review, :get_started

  counters_column :counters_cache, long_format: true
  has_counter :all_projects, 'all_projects.publyc.count'
  has_counter :owners, 'owners.count'
  has_counter :projects, 'projects.publyc.count'

  validates :name, :type, presence: true
  validates :name, length: { maximum: 255 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :slug, uniqueness: { scope: :platform_id }, length: { in: 3..100 },
    format: { with: /\A[a-z0-9\-]+\z/, message: "accepts only lowercase letters, numbers, and dashes '-'." }, allow_blank: true
  validates :one_liner, length: { maximum: 140 }, allow_blank: true
  before_validation :ensure_partable, unless: proc{|p| p.persisted? }
  before_validation :generate_slug, if: proc{|p| p.should_generate_slug or (p.slug.blank? and p.approved?) or (p.slug.present? and p.name_changed?) }
  register_sanitizer :strip_tags, :before_save, :name
  register_sanitizer :strip_whitespace, :before_validation, :mpn, :description, :name
  register_sanitizer :sanitize_description, :before_validation, :description
  after_create proc{|p| p.require_review! if p.workflow_state.blank? or p.new? }

  workflow do
    state :new do
      event :approve, transitions_to: :approved
      event :require_review, transitions_to: :pending_review
      event :retire, transitions_to: :retired
    end
    state :pending_review do
      event :approve, transitions_to: :approved
      event :reject, transitions_to: :rejected
      event :retire, transitions_to: :retired
    end
    state :approved do
      event :feature, transitions_to: :featured
      event :reject, transitions_to: :rejected
      event :retire, transitions_to: :retired
    end
    state :rejected do
      event :approve, transitions_to: :approved
      event :retire, transitions_to: :retired
    end
    state :retired
    # after_transition do |from, to, triggering_event, *event_args|
    #   notify_observers 'after_status_updated' if to.to_s.in? %w(approved rejected)
    # end
  end

  # beginning of search methods
  include AlgoliaSearchHelpers
  has_algolia_index '!approved?'

  def self.index_all limit=nil
    algolia_batch_import where(workflow_state: :approved).includes(:platform, :image), limit
  end

  def to_indexed_json
    {
      # for locating
      id: id,
      model: self.class.model_name.name,
      objectID: algolia_id,

      # for searching
      description: description,
      mpn: mpn,
      name: name,
      pitch: one_liner,
      platforms: [
        platform ? {
          id: platform.id,
          name: platform.name,
        } : nil
      ].compact,
      _tags: product_tags_cached,
      type: type,

      # for display
      image_url: decorate.image(:part_thumb),
      url: UrlGenerator.new(path_prefix: nil, locale: nil).part_path(self),

      # for ranking
      impressions_count: impressions_count,
      owners_count: owners_count,
      projects_count: projects_count,
    }
  end
  # end of search methods

  scope :alphabetical, -> { order name: :asc }
  scope :default_sort, -> { order("parts.position ASC, CAST(parts.counters_cache -> 'all_projects_count' AS INT) DESC NULLS LAST, parts.name ASC") }

  def self.search opts={}
    # escape single quotes and % so it doesn't break the query
    # query = if params[:q].present?
    #   params[:q].gsub(/['%]/, ' ').split(/\s+/).map do |token|
    #     "(parts.name ILIKE '%#{token}%' OR groups.full_name ILIKE '%#{token}%')"
    #   end.join(' AND ')
    # else
    #   '1=1'
    # end

    # approved.joins("LEFT JOIN groups ON groups.id = parts.platform_id AND groups.type = 'Platform'").where(query).includes(:platform)

    params = {}
    params['type'] = opts[:type] if opts[:type]

    search_opts = {
      q: opts[:q],
      per_page: opts[:per_page],
      platform_id: opts[:platform_id],
      model_classes: [
        {
          model_class: 'Part',
          params: params,
          includes: opts[:includes],
          restrictSearchableAttributes: "name,platforms.name,mpn",
        }
      ]
    }

    Search.new(search_opts).hits['part']
  end

  def self.approved
    where workflow_state: :approved
  end

  def self.has_platform
    where.not platform_id: nil
  end

  def self.include_full_name
    select("parts.*, CASE WHEN position(fng.full_name IN parts.name) = 0 THEN CONCAT(fng.full_name, ' ', parts.name) ELSE parts.name END AS fname").joins("LEFT JOIN groups AS fng ON fng.id = parts.platform_id AND fng.type = 'Platform'")
  end

  def self.invalid
    where workflow_state: INVALID_STATES
  end

  def self.most_followed
    order("CAST(parts.counters_cache -> 'owners_count' AS INT) DESC NULLS LAST, parts.name ASC")
  end

  def self.most_used
    order("CAST(parts.counters_cache -> 'all_projects_count' AS INT) DESC NULLS LAST, parts.name ASC")
  end

  def self.not_invalid
    where.not workflow_state: INVALID_STATES
  end

  def self.with_slug
    where("parts.slug IS NOT NULL AND parts.slug <> ''")
  end

  def self.sorted_by_name
    order(:name)
  end

  def self.sorted_by_full_name
    include_full_name.order("fname ASC")
  end

  def self.with_sku
    where("parts.vendor_sku <> '' AND parts.vendor_sku IS NOT NULL")
  end

  def self.without_sku
    where("parts.vendor_sku = '' OR parts.vendor_sku IS NULL")
  end

  def self.visible
    publyc.with_slug
  end

  def all_projects
    ids = [id]
    ids += child_part_relations.pluck(:child_part_id)
    BaseArticle.joins("INNER JOIN part_joins ON part_joins.partable_id = projects.id AND part_joins.partable_type = 'BaseArticle'").where(part_joins: { part_id: ids })
  end

  def editable
    workflow_state.in? EDITABLE_STATES
  end

  def editable?
    editable
  end

  def identifier
    type.underscore.gsub(/_part$/, '')
  end

  def image_id=(val)
    attribute_will_change! :image
    self.image = Image.find_by_id(val)
  end

  def image_url=(val)
    build_image unless image
    image.remote_file_url = val
  end

  def full_name
    return @full_name if @full_name

    @full_name = if platform and !name.downcase.starts_with?(platform.name.downcase)
      "#{platform.name} #{name}"
    else
      name
    end
  end

  def generate_slug
    return if name.blank?

    slug = name.downcase.gsub(/[^a-z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase.truncate(100, omission: '')

    # make sure it doesn't exist
    if result = Part.where(slug: slug, platform_id: platform_id).first
      unless self == result
        # if it exists add a 1 and increment it if necessary
        slug += '1'
        while Part.where(slug: slug, platform_id: platform_id).first
          slug.gsub!(/([0-9]+$)/, ($1.to_i + 1).to_s)
        end
      end
    end
    self.slug = slug
  end

  def has_own_page?
    platform_id.present? and slug.present?
  end

  def search_on_octopart
    return unless description.present? or mpn.present?

    keywords = mpn.presence || description

    if result = Octopart.search(keywords)
      self.vendor_link = result[:octopart_url]
      self.mpn = result[:mpn]
      self.vendor_name = result[:vendor_name] + ' (auto-matched)'
      self.unit_price = result[:price]
      # self.total_cost = unit_price * quantity || 1
      result
    end
  end

  def tags=(val)
    self.product_tags_string = val
  end

  private
    def ensure_partable
      self.partable_id = 0
      self.partable_type = 'Orphan'
    end

    def strip_tags text
      text = ActionController::Base.helpers.strip_tags(text)

      # so that these characters don't show escaped. Not the cleanest...
      {
        '&amp;' => '&',
        '&lt;' => '<',
        '&gt;' => '>',
        '&quot;' => '"',
      }.each do |code, character|
        text.gsub! Regexp.new(code), character
      end
      text
    end

    def sanitize_description text
      if text
        doc = Nokogiri::HTML::DocumentFragment.parse(text)

        {
          'strong' => 'b',
          'h1' => 'p',
          'h2' => 'p',
          'h3' => 'p',
          'h4' => 'p',
          'h5' => 'p',
          'h6' => 'p',
          'em' => 'i',
        }.each do |orig_tag, proper_tag|
          doc.css(orig_tag).each{|el| el.name = proper_tag }
        end

        Sanitize.clean(doc.to_s.encode("UTF-8"), Sanitize::Config::HACKSTER)
      end
    end

    def strip_whitespace text
      text.try(:strip)
    end
end
