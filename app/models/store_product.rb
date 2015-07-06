class StoreProduct < ActiveRecord::Base
  include HstoreColumn
  include HstoreCounter

  has_many :orders, through: :order_lines
  has_many :order_lines
  belongs_to :source, polymorphic: true

  hstore_column :properties, :charge_shipping, :boolean, default: true
  hstore_column :properties, :length, :float
  hstore_column :properties, :height, :float
  hstore_column :properties, :in_stock, :integer, default: 0  # auto lower after order placed
  hstore_column :properties, :limit_per_person, :integer, default: 0
  hstore_column :properties, :real_unit_price, :float
  hstore_column :properties, :stored_actions, :string, default: '[]'
  hstore_column :properties, :weight, :float
  hstore_column :properties, :width, :float

  counters_column :counters_cache
  has_counter :orders, 'orders.valid.count'

  attr_accessible :unit_cost, :source_id, :source_type, :available

  validates :length, :height, :weight, :width, presence: true

  def self.available
    where available: true
  end

  def self.cheapest
    where.not(unit_cost: nil).where.not(unit_cost: 0).order(unit_cost: :asc).first
  end

  def self.by_cost
    order :unit_cost
  end

  def actions
    return @actions if @actions
    json = stored_actions.present? ? JSON.parse(stored_actions) : []
    @actions = StoreProductActionList.new(json)
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
end
