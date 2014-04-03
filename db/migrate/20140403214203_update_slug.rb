class UpdateSlug < ActiveRecord::Migration
  def change
    remove_index :slug_histories, :project_id
    rename_column :slug_histories, :project_id, :sluggable_id
    change_column :slug_histories, :sluggable_id, :integer, null: false
    add_column :slug_histories, :sluggable_type, :string, default: 'Project', null: false
    add_index :slug_histories, [:sluggable_type, :sluggable_id]
  end
end
