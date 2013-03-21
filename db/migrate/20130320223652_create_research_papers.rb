class CreateResearchPapers < ActiveRecord::Migration
  def change
    create_table :publications do |t|
      t.string :title
      t.text :abstract
      t.string :coauthors
      t.date :published_on
      t.string :journal
      t.string :link
      t.integer :user_id, null: false

      t.timestamps
    end
    add_index :publications, :user_id
  end
end
