class OrderObserver < ActiveRecord::Observer
  def after_ship record
    record.update_column :shipped_at, Time.now
  end

  def after_pass_order record
    record.user.reputation.compute_redeemable!
    record.store_products.each do |product|
      product.update_counters only: [:orders]
      product.update_attribute :in_stock, product.in_stock-1
      product.save
    end
    record.update_column :placed_at, Time.now
    NotificationCenter.notify_all :placed, :order, record.id
  end

  def after_ship record
    NotificationCenter.notify_all :shipped, :order, record.id
  end

  def after_update record
    if record.processing? and record.total_cost_changed?
      record.reputation_needs_update = true
    elsif record.workflow_state_changed? and record.shipped?
      after_ship record
    end
  end

  def after_commit_on_update record
    if record.reputation_needs_update
      record.user.reputation.compute_redeemable!
    end
  end

  def before_create record
    record.order_lines_count = 0
  end

  def before_save record
    if (record.changed & %w(address_id)).any?
      record.compute_shipping_cost
    end
    if (record.changed & %w(products_cost)).any?
      record.total_cost = record.compute_total_cost
    end
    if (record.changed & %w(shipping_cost_in_currency)).any?
      OrderPayment.new(record).configure
    end
  end
end