class ChangeFavorite < ActiveRecord::Migration
  def change
    rename_table :favorites, :respects
    rename_column :respects, :user_id, :respecting_id
    add_column :respects, :respecting_type, :string, default: 'User', null: false
    remove_index :respects, :respecting_id
    add_index :respects, [:respecting_id, :respecting_type]
  end
end

# Broadcast.where(context_model_type: 'Favorite').update_all(context_model_type: 'Respect')