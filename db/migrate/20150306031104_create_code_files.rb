class CreateCodeFiles < ActiveRecord::Migration
  def change
    create_table :code_files do |t|
      t.string :name
      t.text :raw_code
      t.text :formatted_code
      t.string :language
      t.string :directory
      t.string :project_id

      t.timestamps
    end
  end
end
