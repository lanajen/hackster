class AddReviewedToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :approved, :boolean
  end
end
