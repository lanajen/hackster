class ProjectCollectionObserver < ActiveRecord::Observer
  def after_create record
    update_counters record
    update_project record.project if record.collectable_type == 'Assignment'
  end

  def after_destroy record
    update_counters record
  end

  def after_update record
    update_project record.project if record.collectable_id_changed? and record.collectable_type == 'Assignment'
  end

  private
    def update_counters record
      record.collectable.update_counters only: [:projects, :external_projects, :private_projects] if record.collectable.class == Tech
    end

    def update_project project
      Cashier.expire "project-#{project.id}-teaser"

      project.hide = true if project.assignment.try(:hide_all)
      if project.issues.empty?
        issue = project.issues.new title: 'Feedback'
        issue.type = 'Feedback'
        issue.user_id = 0
        issue.save
      end
      project.save
    end
end