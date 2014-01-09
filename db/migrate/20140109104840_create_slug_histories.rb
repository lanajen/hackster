class CreateSlugHistories < ActiveRecord::Migration
  def change
    create_table :slug_histories do |t|
      t.string :value, null: false
      t.integer :project_id, null: false

      t.timestamps
    end
    add_index :slug_histories, :value
    add_index :slug_histories, :project_id
  end
end
