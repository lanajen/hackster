class CreateChallengeCategories < ActiveRecord::Migration
  def change
    create_table :challenge_categories do |t|
      t.integer :challenge_id, null: false
      t.string :name
    end
    add_index :challenge_categories, :challenge_id

    add_column :challenge_projects, :category_id, :integer
  end
end
