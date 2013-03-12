class CreateWebsites < ActiveRecord::Migration
  def change
    create_table :websites do |t|
      t.string :url
      t.integer :user_id, null: false

      t.timestamps
    end
    add_index :websites, :user_id
  end
end
