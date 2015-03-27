class CreateCodeFiles < ActiveRecord::Migration
  def change
    create_table :code_files do |t|
      t.string :name
      t.text :raw_code
      t.text :formatted_code
      t.string :language
      t.string :directory
      t.string :project_id, null: false
      t.string :repository
      t.integer :position
      t.text :comment
      t.string :device
      t.boolean :compiles

      t.timestamps
    end
    add_index :code_files, :project_id
  end
end
