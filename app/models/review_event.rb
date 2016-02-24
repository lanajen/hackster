class ReviewEvent < ActiveRecord::Base
  include HstoreColumn

  # examples:
  # - project was updated (could specify which fields, even the diff): "user x updated the project's title"
  # - project privacy was udpated
  # - project workflow_state updated: "user x marked the project as approved"
  # - review thread marked closed: "review thread closed automatically after decision was made"
  belongs_to :review_thread
  belongs_to :user

  hstore_column :meta, :new_project_privacy, :boolean
  hstore_column :meta, :new_project_workflow_state, :string
  hstore_column :meta, :project_changed_fields, :array

  def has_user?
    !user_id.zero?
  end
end
