class ReviewEventDecorator < ApplicationDecorator
  def message
    case model.event.to_sym
    when :project_privacy_update
      if model.new_project_privacy
        'made the project private'
      else
        'published the project'
      end
    when :project_update
      "updated the project"
    when :project_status_update
      if model.has_user?
        "marked the project as #{model.new_project_workflow_state}"
      else
        "The project was marked as #{model.new_project_workflow_state}"
      end
    when :thread_closed
      "Review thread closed automatically after decision was made"
    else
      raise "Unknown event: `#{model.event}`"
    end
  end
end