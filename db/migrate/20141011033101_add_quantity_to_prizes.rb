class AddQuantityToPrizes < ActiveRecord::Migration
  def change
    add_column :prizes, :quantity, :integer, default: 1
  end
end
