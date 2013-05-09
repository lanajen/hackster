class AddCategoriesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :categories_mask, :integer
  end
end
