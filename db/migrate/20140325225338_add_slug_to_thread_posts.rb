class AddSlugToThreadPosts < ActiveRecord::Migration
  def change
    add_column :threads, :slug, :string
  end
end
