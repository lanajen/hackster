class StageDecorator < ApplicationDecorator
  def next_step
    if model.completion_rate < 100
      if model.widgets.empty?
        return h.link_to 'Add your first component', h.new_stage_widget_path(model)
      else
        model.widgets.each do |widget|
          if widget.completion_rate < 100
            widget.issues.where(workflow_state: :unresolved).each do |issue|
              return h.link_to "Resolve this issue: #{issue.title}", h.issue_path(issue)
            end
            return h.link_to "Complete #{widget.name}", "#widget-#{widget.id}"
          end
        end
        return h.link_to 'Add a new component', h.new_stage_widget_path(model)
      end
    else
      if model.open?
        return h.link_to "Mark this stage as complete", h.update_workflow_stage_path(model, event: :complete), method: :patch
      end
    end
    "Nothing to do"
  end
end