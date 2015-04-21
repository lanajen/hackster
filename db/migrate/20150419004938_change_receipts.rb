class ChangeReceipts < ActiveRecord::Migration
  def change
    remove_index :receipts, :message_id
    rename_column :receipts, :message_id, :receivable_id
    add_column :receipts, :receivable_type, :string, null: false, default: 'Comment'
    add_index :receipts, [:receivable_id, :receivable_type]
  end
end
