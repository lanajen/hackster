class AddOrderedAtToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :placed_at, :datetime
    add_column :orders, :shipped_at, :datetime
  end
end
