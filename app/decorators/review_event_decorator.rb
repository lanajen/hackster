class ReviewEventDecorator < ApplicationDecorator
  def message
    case model.event.to_sym
    when :project_privacy_update
      if model.new_project_privacy
        'made the project private'
      else
        'made the project public'
      end
    when :project_update
      "updated the project"
    when :project_status_update
      if model.new_project_workflow_state == 'pending_review'
        if model.has_user?
          "published the project"
        else
          "The project was published"
        end
      else
        if model.has_user?
          "marked the project as #{model.new_project_workflow_state}"
        else
          "The project was marked as #{model.new_project_workflow_state}"
        end
      end
    when :thread_closed
      "Review thread closed automatically after decision was made"
    else
      raise "Unknown event: `#{model.event}`"
    end
  end
end