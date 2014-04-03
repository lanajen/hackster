class AddLayoutToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :layout, :text
  end
end
