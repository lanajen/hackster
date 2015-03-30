class AddDifficultyToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :difficulty, :string
  end
end
