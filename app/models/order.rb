# TODO:
# => email notif when shipped

class Order < ActiveRecord::Base
  include ApplicationHelper
  include HstoreCounter
  include Workflow

  INVALID_STATES = %w(new).freeze
  REDUCED_SHIPPING_COUNTRIES = ['United States'].freeze
  REDUCED_SHIPPING_COST = 50
  INTERNATIONAL_SHIPPING_COST = 100

  belongs_to :address
  belongs_to :user
  has_many :order_lines, dependent: :destroy
  has_many :store_products, through: :order_lines

  attr_accessible :tracking_number, :address_id, :workflow_state,
    :order_lines_attributes

  attr_accessor :reputation_needs_update

  accepts_nested_attributes_for :order_lines, allow_destroy: true

  counters_column :counters_cache
  has_counter :order_lines, 'order_lines.count.count'

  workflow do
    state :new do
      event :pass_order, transitions_to: :processing, if: :can_pass_order?
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

  def self.this_month
    where "orders.placed_at > ?", Date.today.beginning_of_month
  end

  def self.valid
    where.not workflow_state: INVALID_STATES
  end

  def add_to_cart product
    order_lines.create store_product_id: product.id
  end

  def after_points
    user.reputation.redeemable_points - total_cost.to_i
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

  def destination_country
    address.try(:country)
  end

  def enough_points?
    total_cost and total_cost <= user.reputation.redeemable_points
  end

  def can_pass_order?
    validate_address_is_present
    validate_at_least_one_order_line
    validate_has_enough_points
    validate_order_limits

    errors.empty?
  end

  def points_delta
    user.reputation.redeemable_points - total_cost.to_i
  end

  private
    def compute_costs
      compute_shipping_cost
      compute_products_cost
      compute_total_cost
    end

    def validate_address_is_present
      errors.add :address_id, 'is required' unless address_id.present?
    end

    def validate_at_least_one_order_line
      errors.add :order_lines, 'at least one item is required' unless order_lines_count.to_i > 0
    end

    def validate_has_enough_points
      errors.add :total_cost, "You don't have enough points (#{-points_delta} missing)." unless enough_points?
    end

    def validate_order_limits
      errors.add :base, "You've reached the limit of one item per person per month during the trial phase. #{time_diff_in_natural_language Date.today, Date.today.beginning_of_month + 1.month} left before you can place a new order." if user.orders.valid.this_month.count >= 1 or user.total_orders_this_month >= 1
      errors.add :base, "You can only order one item per month during the trial phase. Please choose your favorite and remove the others from the cart." if order_lines_count.to_i > 1
    end
end
