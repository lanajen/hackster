class AddOpenSourceToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :open_source, :boolean, default: true
  end
end
