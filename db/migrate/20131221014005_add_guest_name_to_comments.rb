class AddGuestNameToComments < ActiveRecord::Migration
  def change
    change_column :comments, :user_id, :integer, default: 0
    add_column :comments, :guest_name, :string
  end
end
