class AssignmentObserver < ActiveRecord::Observer
  def after_update record
    if record.private_grades_changed? and !record.private_grades
      record.projects.each do |project|
        project.locked = false
        project.save
      end

      record.grades.each do |grade|
        BaseMailer.enqueue_email 'grade_notification',
          { context_type: 'grade', context_id: grade.id }
        record.projects.each{ |p| p.update_attribute :locked, false }
      end
    end
  end
end