class StoreProduct < ActiveRecord::Base
  include Counter
  include StringParser

  has_many :orders, through: :order_lines
  has_many :order_lines
  belongs_to :source, polymorphic: true

  store_accessor :counters_cache, :orders_count
  parse_as_integers :counters_cache, :orders_count

  attr_accessible :unit_cost, :source_id, :source_type, :available

  def self.available
    where available: true
  end

  def self.by_cost
    order :unit_cost
  end

  def counters
    {
      orders: "orders.valid.count",
    }
  end
end
