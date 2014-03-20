class ChangeAssignmentId < ActiveRecord::Migration
  def change
    rename_column :projects, :assignment_id, :collection_id
  end
end
