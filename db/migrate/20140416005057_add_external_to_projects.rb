class AddExternalToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :external, :boolean, default: false
  end
end
