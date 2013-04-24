class CreateThreads < ActiveRecord::Migration
  def change
    rename_table :blog_posts, :threads
    add_column :threads, :type, :string, limit: 20
    rename_column :threads, :bloggable_id, :threadable_id
    rename_column :threads, :bloggable_type, :threadable_type
  end
end
