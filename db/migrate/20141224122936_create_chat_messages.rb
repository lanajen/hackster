class CreateChatMessages < ActiveRecord::Migration
  def change
    create_table :chat_messages do |t|
      t.integer :user_id, null: false
      t.text :body
      t.integer :group_id, null: false

      t.timestamps
    end
    add_index :chat_messages, :group_id
  end
end
