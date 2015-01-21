class AddCommentsToProjectCollections < ActiveRecord::Migration
  def change
    add_column :project_collections, :comment, :text
  end
end
