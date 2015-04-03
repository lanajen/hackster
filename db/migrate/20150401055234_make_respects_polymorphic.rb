class MakeRespectsPolymorphic < ActiveRecord::Migration
  def change
    remove_index :respects, :project_id
    remove_index :respects, [:respecting_id, :respecting_type]
    rename_column :respects, :respecting_id, :user_id
    change_column :respects, :user_id, :integer, null: false
    rename_column :respects, :project_id, :respectable_id
    change_column :respects, :respectable_id, :integer, null: false
    add_column :respects, :respectable_type, :string, limit: 15, default: 'Project', null: false
    remove_column :respects, :respecting_type
    add_index :respects, :user_id
    add_index :respects, [:respectable_id, :respectable_type]
  end
end
