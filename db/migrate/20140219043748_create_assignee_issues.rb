class CreateAssigneeIssues < ActiveRecord::Migration
  def change
    create_table :assignee_issues do |t|
      t.integer :assignee_id, null: false
      t.integer :issue_id, null: false

      t.timestamps
    end
    add_index :assignee_issues, :assignee_id
    add_index :assignee_issues, :issue_id
  end
end
