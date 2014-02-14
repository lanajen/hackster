class AddAssignementToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :assignment_id, :integer
  end
end
