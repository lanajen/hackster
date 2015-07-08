class AddressObserver < ActiveRecord::Observer
  def after_save record
    if (record.default_changed? or record.deleted) and record.default
      record.addressable.addresses.where.not(id: record.id).update_all(default: false)
    end
  end

  def after_update record
    if record.deleted_changed? and record.deleted
      Order.new_state.where(address_id: record.id).update_all(address_id: nil, shipping_cost_in_currency: nil)
    end
  end
end