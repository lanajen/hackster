class ChangeTypeOfTagsToProjects < ActiveRecord::Migration
  def change
    change_column :projects, :product_tags_string, :text
  end
end
