class AddSubmissionInfoToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :submit_by_date, :datetime
    add_column :assignments, :reminder_sent_at, :datetime
    add_column :projects, :assignment_submitted_at, :datetime
  end
end

# submit old assignments