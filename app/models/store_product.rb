class StoreProduct < ActiveRecord::Base
  include HstoreColumn
  include HstoreCounter

  has_one :image, as: :attachable, dependent: :destroy
  has_many :orders, through: :order_lines
  has_many :order_lines
  belongs_to :source, polymorphic: true

  hstore_column :properties, :charge_shipping, :boolean, default: true
  hstore_column :properties, :length, :float
  hstore_column :properties, :height, :float
  hstore_column :properties, :in_stock, :integer, default: 0  # auto decrease by 1 after order placed
  hstore_column :properties, :limit_per_person, :integer, default: 0
  hstore_column :properties, :one_liner, :string
  hstore_column :properties, :real_unit_price, :float
  hstore_column :properties, :stored_actions, :string, default: '[]'
  hstore_column :properties, :weight, :float
  hstore_column :properties, :width, :float

  counters_column :counters_cache
  has_counter :orders, 'orders.valid.count'

  attr_accessible :unit_cost, :source_id, :source_type, :available, :name,
    :description, :image_id

  validates :length, :height, :weight, :width, presence: true, if: proc{|p| p.charge_shipping? }
  validate :has_source
  before_validation :ensure_source_id

  def self.available
    where available: true
  end

  def self.cheapest
    where.not(unit_cost: nil).where.not(unit_cost: 0).order(unit_cost: :asc).first
  end

  def self.unavailable_last
    order("(CASE WHEN store_products.properties -> 'in_stock' = '0' THEN 1 ELSE 0 END) ASC");
  end

  def self.by_cost
    order :unit_cost
  end

  def actions
    return @actions if @actions
    json = stored_actions.present? ? JSON.parse(stored_actions) : []
    @actions = StoreProductActionList.new(json)
  end

  def image_id
    image.try(:id)
  end

  def image_id=(val)
    self.image = Image.find_by_id val
  end

  def in_stock?
    in_stock > 0
  end

  def is_limited_per_person?
    limit_per_person > 0
  end

  def limit_reached_for? user
    is_limited_per_person? and user.orders.valid.joins(:store_products).where(store_products: { id: id }).count + 1 > limit_per_person
  end

  def shipping_cost_to address
    @shipping_costs ||= {}
    @shipping_costs[address.id] ||= ShippingCostCalculator.new(self, address).cost
  end

  private
    def ensure_source_id
      self.source_id = 0 unless source_id
    end

    def has_source
      errors.add :source, 'is required' if source.nil? and name.blank?
    end
end
