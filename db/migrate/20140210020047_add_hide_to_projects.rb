class AddHideToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :hide, :boolean, default: false
  end
end
