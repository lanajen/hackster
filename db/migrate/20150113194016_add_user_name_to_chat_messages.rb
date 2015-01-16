class AddUserNameToChatMessages < ActiveRecord::Migration
  def change
    add_column :chat_messages, :user_name, :string
    add_column :chat_messages, :source, :string
    add_column :chat_messages, :raw_body, :text
  end
end
