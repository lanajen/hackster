class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.integer :user_id
      t.integer :project_id

      t.timestamps
    end
    add_index :favorites, :user_id
    add_index :favorites, :project_id
  end
end
