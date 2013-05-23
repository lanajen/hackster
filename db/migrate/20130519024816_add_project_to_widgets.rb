class AddProjectToWidgets < ActiveRecord::Migration
  def change
    add_column :widgets, :project_id, :integer, null: false#, default: 0
    add_index :widgets, :project_id
  end
end
