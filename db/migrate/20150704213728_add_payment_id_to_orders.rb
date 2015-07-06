class AddPaymentIdToOrders < ActiveRecord::Migration
  def up
    add_column :payments, :payable_id, :integer
    add_column :payments, :payable_type, :string
    add_column :payments, :stripe_token, :string
    change_column :payments, :amount, :float
  end

  def down
    remove_column :payments, :payable_id
    remove_column :payments, :payable_type
    remove_column :payments, :stripe_token
    change_column :payments, :amount, :integer
  end
end
