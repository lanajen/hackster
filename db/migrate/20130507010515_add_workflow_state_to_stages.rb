class AddWorkflowStateToStages < ActiveRecord::Migration
  def change
    add_column :stages, :workflow_state, :string
  end
end
