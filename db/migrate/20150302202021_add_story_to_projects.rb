class AddStoryToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :story, :text
  end
end
