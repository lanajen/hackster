class AddWorkflowToThreadPosts < ActiveRecord::Migration
  def change
    add_column :threads, :workflow_state, :string
  end
end
