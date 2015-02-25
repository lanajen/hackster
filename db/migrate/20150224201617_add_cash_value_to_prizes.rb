class AddCashValueToPrizes < ActiveRecord::Migration
  def change
    add_column :prizes, :cash_value, :integer
  end
end
