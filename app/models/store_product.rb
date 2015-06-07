class StoreProduct < ActiveRecord::Base
  include HstoreCounter

  has_many :orders, through: :order_lines
  has_many :order_lines
  belongs_to :source, polymorphic: true

  counters_column :counters_cache
  has_counter :orders, 'orders.valid.count'

  attr_accessible :unit_cost, :source_id, :source_type, :available

  def self.available
    where available: true
  end

  def self.by_cost
    order :unit_cost
  end
end
