class AddOneLinerToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :one_liner, :string
  end
end
