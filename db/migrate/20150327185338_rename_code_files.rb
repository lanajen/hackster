class RenameCodeFiles < ActiveRecord::Migration
  def change
    rename_table :code_files, :code_entities
    add_column :code_entities, :type, :string, limit: 15
  end
end
