class OrderLineObserver < ActiveRecord::Observer
  def after_create record
    order = record.order
    order.compute_products_cost
    order.update_counters only: [:order_lines]
    order.save
  end

  alias_method :after_destroy, :after_create
end