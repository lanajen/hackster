class AddWorkflowStateToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :workflow_state, :string
  end
end
