class AddPropertiesToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :properties, :text
  end
end
