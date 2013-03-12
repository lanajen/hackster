class CreateProjectFollowers < ActiveRecord::Migration
  def change
    create_table :project_followers, id: false do |t|
      t.integer :user_id, null: false
      t.integer :project_id, null: false
    end
    add_index :project_followers, :user_id
    add_index :project_followers, :project_id
  end
end
