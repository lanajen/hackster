class ReviewThreadObserver < ActiveRecord::Observer
  def before_create record
    project = record.project
    return unless project

    if project.needs_review?
      record.workflow_state = :needs_review
    elsif project.approved? or project.rejected?
      event = record.events.new
      event.event = :project_status_update
      event.new_project_workflow_state = project.workflow_state
      event.user_id = project.reviewer_id if project.reviewer_id
      event.created_at = project.review_time || project.made_public_at || project.created_at

      record.workflow_state = :closed
    end
  end
end