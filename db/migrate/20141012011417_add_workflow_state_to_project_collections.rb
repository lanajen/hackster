class AddWorkflowStateToProjectCollections < ActiveRecord::Migration
  def change
    add_column :project_collections, :workflow_state, :string
  end
end
