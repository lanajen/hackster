class AddSlugToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :slug, :string, limit: 105
  end
end
