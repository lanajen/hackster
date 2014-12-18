class CreateReceipts < ActiveRecord::Migration
  def change
    create_table :receipts do |t|
      t.integer :user_id
      t.integer :message_id
      t.integer :conversation_id
      t.boolean :read, default: false
      t.boolean :deleted, default: false

      t.timestamps
    end
    add_index :receipts, :user_id
    add_index :receipts, :message_id
    add_index :receipts, :conversation_id
  end
end
