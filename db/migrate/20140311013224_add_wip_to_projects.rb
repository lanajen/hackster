class AddWipToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :wip, :boolean, default: false
  end
end
