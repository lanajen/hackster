class CreateProjectCollections < ActiveRecord::Migration
  def change
    create_table :project_collections do |t|
      t.integer :project_id
      t.integer :collectable_id
      t.string :collectable_type

      t.timestamps
    end
  end
end
