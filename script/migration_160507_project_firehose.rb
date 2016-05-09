BaseArticle.where.not(made_public_at: nil).update_all("featured_date = made_public_at")

BaseArticle.where.not(workflow_state: %w(new unpublished)).joins(:review_thread).includes(review_thread: :events).find_each do |project|
  if event = project.review_thread.events.where(event: :project_status_update).select{|e| e.new_project_workflow_state == 'pending_review' }.first
    project.update_column :made_public_at, event.created_at
  end
end; nil

BaseArticle.published.where(made_public_at: nil).update_all("made_public_at = created_at")