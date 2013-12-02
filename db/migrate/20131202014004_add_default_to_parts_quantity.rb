class AddDefaultToPartsQuantity < ActiveRecord::Migration
  def change
    change_column :parts, :quantity, :integer, default: 1
    change_column :parts, :unit_price, :float, default: 0
    change_column :parts, :total_cost, :float, default: 0
  end
end
