class AddPlatformIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :origin_platform_id, :integer, default: 0, null: false
    add_index :projects, :origin_platform_id
  end
end
