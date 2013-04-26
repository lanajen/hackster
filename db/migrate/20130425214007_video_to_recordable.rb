class VideoToRecordable < ActiveRecord::Migration
  def up
    remove_index :videos, :project_id
    rename_column :videos, :project_id, :recordable_id
    change_column :videos, :recordable_id, :integer, null: false
    add_column :videos, :recordable_type, :string, null: false, default: ''
    add_index :videos, [:recordable_id, :recordable_type], name: :recordable_index
  end

  def down
  end
end
