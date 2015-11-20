class CreateShortLinks < ActiveRecord::Migration
  def change
    create_table :short_links do |t|
      t.string :slug, limit: 30
      t.string :redirect_to_url
      t.integer :impressions_count

      t.timestamps null: false
    end
    add_index :short_links, :slug
  end
end
