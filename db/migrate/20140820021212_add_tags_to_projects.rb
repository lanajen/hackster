class AddTagsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :tech_tags_string, :string
    add_column :projects, :product_tags_string, :string
  end
end
