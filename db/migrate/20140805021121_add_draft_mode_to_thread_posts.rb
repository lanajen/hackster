class AddDraftModeToThreadPosts < ActiveRecord::Migration
  def change
    add_column :threads, :draft, :boolean, default: false
    add_index :threads, :draft
  end
end
