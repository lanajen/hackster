class AddDontShareMyProfileToUsers < ActiveRecord::Migration
  def change
    add_column :users, :enable_sharing, :boolean, default: true, null: false
    add_index :users, :enable_sharing
  end
end
