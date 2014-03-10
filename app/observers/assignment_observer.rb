class AssignmentObserver < ActiveRecord::Observer
  def after_update record
    if record.private_grades_changed? and !record.private_grades
      record.grades.each do |grade|
        BaseMailer.enqueue_email 'grade_notification',
          { context_type: 'grade', context_id: grade.id }
      end
    end
  end
end