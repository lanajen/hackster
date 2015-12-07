class AddDestroyedToComments < ActiveRecord::Migration
  def change
    add_column :comments, :deleted, :boolean, default: false
    add_index :comments, :deleted
  end
end
