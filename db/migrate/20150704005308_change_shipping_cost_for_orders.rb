class ChangeShippingCostForOrders < ActiveRecord::Migration
  def change
    add_column :orders, :shipping_cost_in_currency, :float
  end
end
