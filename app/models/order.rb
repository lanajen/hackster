# FAQS:
# => what is the store? how does it work and how to get free stuff?
# => about my order: when will I receive it?
# => do you offer other products?
# => what about spam?
# TODO:
# => enforce limits (max 1000 points or one product per month)
# => email notif when shipped

class Order < ActiveRecord::Base
  include Counter
  include StringParser
  include Workflow

  INVALID_STATES = %w(new).freeze
  REDUCED_SHIPPING_COUNTRIES = ['United States'].freeze
  REDUCED_SHIPPING_COST = 50
  INTERNATIONAL_SHIPPING_COST = 100

  belongs_to :address
  belongs_to :user
  has_many :order_lines, dependent: :destroy
  has_many :store_products, through: :order_lines

  # validate address_id present and run compute_costs on transition to :order

  attr_accessible :tracking_number, :address_id, :workflow_state,
    :order_lines_attributes

  attr_accessor :reputation_needs_update

  accepts_nested_attributes_for :order_lines, allow_destroy: true

  store_accessor :counters_cache, :order_lines_count
  parse_as_integers :counters_cache, :order_lines_count

  workflow do
    state :new do
      event :pass_order, transitions_to: :processing
    end
    state :processing do
      event :ship, transitions_to: :shipped
    end
    state :shipped
    after_transition do |from, to, triggering_event, *event_args|
      notify_observers(:"after_#{triggering_event}")
    end
    # on_transition do |from, to, triggering_event, *event_args|
    #   notify_observers(:"before_#{triggering_event}")
    # end
    after_transition do |from, to, triggering_event, *event_args|
      notify_observers(:"after_#{triggering_event}")
    end
  end

  def self.new_state
    where workflow_state: :new
  end

  def self.not_new
    where.not workflow_state: :new
  end

  def self.processing
    where workflow_state: :processing
  end

  def self.valid
    where.not workflow_state: INVALID_STATES
  end

  def add_to_cart product
    order_lines.create store_product_id: product.id
  end

  def after_points
    total_cost ? user.reputation.redeemable_points - total_cost : user.reputation.redeemable_points
  end

  def compute_products_cost!
    update_attribute :products_cost, compute_products_cost
  end

  def compute_products_cost
    self.products_cost = store_products.sum(:unit_cost)
  end

  def compute_shipping_cost
    self.shipping_cost = if address
      destination_country.in?(REDUCED_SHIPPING_COUNTRIES) ? REDUCED_SHIPPING_COST : INTERNATIONAL_SHIPPING_COST
    end
  end

  def compute_total_cost
    self.total_cost = shipping_cost.to_i + products_cost.to_i
  end

  def counters
    {
      order_lines: "order_lines.count",
    }
  end

  def destination_country
    address.try(:country)
  end

  def enough_points?
    total_cost and total_cost <= user.reputation.redeemable_points
  end

  def good_to_go?
    address and order_lines_count and order_lines_count > 0 and enough_points?
  end

  def pass_order
    errors = []
    errors << 'you need to select an address' unless address
    errors << 'you need at least one item in your cart' unless order_lines and order_lines_count > 0
    errors << "you don't have enough points" unless enough_points?
    halt! errors.to_sentence if errors.any?
  end

  def points_delta
    user.reputation.redeemable_points - total_cost if total_cost
  end

  private
    def compute_costs
      compute_shipping_cost
      compute_products_cost
      compute_total_cost
    end
end
