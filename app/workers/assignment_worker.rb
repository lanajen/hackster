class AssignmentWorker < BaseWorker
  def unlock_and_release_grades id
    assignment = Assignment.find id
    assignment.projects.each{ |p| p.update_attribute :locked, false }

    assignment.grades.each do |grade|
      NotificationCenter.notify_all :new, :grade, grade.id
    end
  end
end