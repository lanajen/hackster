class AssignmentObserver < ActiveRecord::Observer
  def after_update record
    if record.private_grades_changed? and !record.private_grades
      AssignmentWorker.perform_async 'unlock_and_release_grades', record.id
    end
  end
end