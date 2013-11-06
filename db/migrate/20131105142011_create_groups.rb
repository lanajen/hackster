class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :user_name, limit: 100
      t.string :city, limit: 50
      t.string :country, limit: 50
      t.string :mini_resume, limit: 160
      t.string :full_name
      t.string :email
      t.text :websites
      t.string :type, null: false, default: 'Group', limit: 15
      t.integer :impressions_count, default: 0
      t.text :counters_cache

      t.timestamps
    end
    add_index :groups, :type
  end
end
