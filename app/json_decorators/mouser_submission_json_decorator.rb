class MouserSubmissionJsonDecorator < BaseJsonDecorator
  def node
    projectWithAuthor = model.project.to_js
    node = hash_for(%w(id))
    node[:author] = projectWithAuthor[:author]
    node[:date] = model.created_at
    node[:project] = projectWithAuthor.except(:author)
    node[:status] = model.workflow_state
    node[:vendor] = model.vendor_user_name
    node
  end
end