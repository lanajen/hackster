class PolymorphizeWidget < ActiveRecord::Migration
  def change
    rename_column :widgets, :project_id, :widgetable_id
    add_column :widgets, :widgetable_type, :string, default: 'Project'
  end
end
