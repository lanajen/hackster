# - use elastic for search
# - clean up parts/consolidate
# - part moderation dashboard
# - later: search by part
# - later: show parts on platform page

class Part < ActiveRecord::Base
  INVALID_STATES = %w(rejected retired)
  include Counter
  include SetChangesForStoredAttributes
  include StringParser
  include Taggable
  include Workflow

  belongs_to :platform
  has_many :part_joins, dependent: :destroy
  has_many :parts_widgets, through: :part_joins, source: :partable, class_name: 'PartsWidget'
  has_many :projects, through: :parts_widgets, source_type: 'Project', source: :widgetable
  has_one :image, as: :attachable, dependent: :destroy

  taggable :product_tags

  attr_accessible :name, :vendor_link, :vendor_name, :vendor_sku, :mpn, :unit_price,
    :description, :store_link, :documentation_link, :libraries_link,
    :datasheet_link, :product_page_link, :image_id, :platform_id,
    :part_joins_attributes, :part_join_ids, :workflow_state, :slug

  accepts_nested_attributes_for :part_joins, allow_destroy: true

  store :websites, accessors: [:store_link, :documentation_link, :libraries_link,
    :datasheet_link, :product_page_link]
  set_changes_for_stored_attributes :websites

  store :counters_cache, accessors: [:projects_count]
  parse_as_integers :counters_cache, :projects_count

  validates :name, presence: true
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :slug, uniqueness: { scope: :platform_id }, presence: true
  before_validation :ensure_website_protocol
  before_validation :ensure_partable, unless: proc{|p| p.persisted? }
  before_validation :generate_slug, if: proc{|p| p.slug.blank? }
  register_sanitizer :strip_whitespace, :before_validation, :mpn, :description
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

  # # beginning of search methods
  # include TireInitialization

  # def self.tire_index_name
  #   ELASTIC_SEARCH_INDEX_NAME + '-parts'
  # end

  # has_tire_index '!approved?', self.tire_index_name

  # tire do
  #   settings analysis: {
  #     filter: {
  #       ngram_filter: {
  #         type: 'nGram',
  #         min_gram: 3,
  #         max_gram: 8
  #       }
  #     },
  #     analyzer: {
  #       ngram_analyzer: {
  #         type: 'custom',
  #         tokenizer: 'standard',
  #         filter: ['lowercase', 'ngram_filter']
  #       },
  #       index_ngram_analyzer: {
  #         type: 'custom',
  #         tokenizer: 'standard',
  #         filter: ['lowercase', 'ngram_filter']
  #       },
  #       search_ngram_analyzer: {
  #         type: 'custom',
  #         tokenizer: 'standard',
  #         filter: ['lowercase']
  #       }
  #     }
  #   } do
  #     mapping do
  #       indexes :id,              index: :not_analyzed
  #       indexes :name,            boost: 100, type: 'string', analyzer: 'ngram_analyzer', index_analyzer: "index_ngram_analyzer", search_analyzer: "search_ngram_analyzer"
  #       # indexes :description,     analyzer: 'snowball', type: 'string', index_analyzer: "index_ngram_analyzer", search_analyzer: "search_ngram_analyzer"
  #       # indexes :product_tags,    analyzer: 'snowball', type: 'string', index_analyzer: "index_ngram_analyzer", search_analyzer: "search_ngram_analyzer"
  #       # indexes :mpn,             analyzer: 'snowball', boost: 100, type: 'string', index_analyzer: "index_ngram_analyzer", search_analyzer: "search_ngram_analyzer"
  #       indexes :created_at
  #     end
  #   end
  # end

  # def to_indexed_json
  #   {
  #     _id: id,
  #     name: name,
  #     # description: description,
  #     # mpn: mpn,
  #     # product_tags: product_tags_string,
  #     created_at: created_at,
  #   }.to_json
  # end

  # def self.index_all
  #   index.import approved
  # end

  # def self.search params
  #   query = params[:q] ? CGI::unescape(params[:q].to_s) : nil

  #   query = params[:q]
  #   per_page = params[:per_page] || 50
  #   page = params[:page] || 1
  #   offset = params[:offset]

  #   Rails.logger.info "Searching parts for #{query} (offset: #{offset}, page: #{page}, per_page: #{per_page})"
  #   results = Tire.search index_name, load: true, page: page, per_page: per_page do
  #     query do
  #       # string query, default_operator: 'AND'
  #       # match :name, query
  #       # string "name:#{query}", default_operator: "OR"
  #       boolean do
  #         should { string "name:#{query}", default_operator: "OR" }
  #       end
  #     end
  #     size per_page
  #     from (offset || (per_page.to_i * (page.to_i-1)))
  #   end

  #   results.results
  # end
  # end of search methods

  def self.search params
    query = params[:q].split(/\s+/).map do |token|
      "(parts.description ILIKE '%#{token}%' OR parts.name ILIKE '%#{token}%' OR parts.product_tags_string ILIKE '%#{token}%')"
    end.join(' AND ')

    where(query)
  end

  def self.approved
    where workflow_state: :approved
  end

  def self.invalid
    where workflow_state: INVALID_STATES
  end

  def self.not_invalid
    where.not workflow_state: INVALID_STATES
  end

  def self.with_sku
    where("parts.vendor_sku <> '' AND parts.vendor_sku IS NOT NULL")
  end

  def self.without_sku
    where("parts.vendor_sku = '' OR parts.vendor_sku IS NULL")
  end

  def counters
    {
      projects: 'projects.public.count',
    }
  end

  def image_id=(val)
    self.image = Image.find_by_id(val)
  end

  def full_name
    if platform
      "#{platform.name} #{name}"
    else
      name
    end
  end

  def generate_slug
    return if name.blank?

    slug = name.downcase.gsub(/[^a-z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase

    # make sure it doesn't exist
    if result = self.class.where(slug: slug, platform_id: platform_id).first
      unless self == result
        # if it exists add a 1 and increment it if necessary
        slug += '1'
        while self.class.where(slug: slug, platform_id: platform_id).first
          slug.gsub!(/([0-9]+$)/, ($1.to_i + 1).to_s)
        end
      end
    end
    self.slug = slug
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

  private
    def ensure_partable
      self.partable_id = 0 if partable_id.nil?
      self.partable_type = 'Orphan' if partable_type.nil?
    end

    def ensure_website_protocol
      return unless websites_changed?
      websites.each do |type, url|
        if url.blank?
          send "#{type}=", nil
          next
        end
        send "#{type}=", 'http://' + url unless url =~ /^http/
      end
    end

    def strip_whitespace text
      text.strip
    end
end
