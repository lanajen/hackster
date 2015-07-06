class OrderLineObserver < ActiveRecord::Observer
  def after_create record
    order = record.order
    order.compute_products_cost
    order.update_counters only: [:order_lines]
    order.compute_shipping_cost
    order.save
  end

  alias_method :after_destroy, :after_create
end