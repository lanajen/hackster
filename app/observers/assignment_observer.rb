class AssignmentObserver < ActiveRecord::Observer
  def after_update record
    if record.private_grades_changed? and !record.private_grades
      record.projects.each{ |p| p.update_attribute :locked, false }

      record.grades.each do |grade|
        NotificationCenter.notify_all :new, :grade, grade.id
      end
    end
  end
end