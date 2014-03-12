class ProjectObserver < ActiveRecord::Observer
  def after_create record
    update_counters record, :projects
  end

  def after_destroy record
    Broadcast.where(context_model_id: record.id, context_model_type: 'Project').destroy_all
    Broadcast.where(project_id: record.id).destroy_all
    update_counters record, [:projects, :live_projects]
    record.team.destroy if record.team
  end

  def after_save record
    record.product_tags_count = record.product_tags_string.split(',').count
    # record.product_tags.each{|t| t.touch }
    SlugHistory.update_history_for record.id
  end

  def after_update record
    if record.private_changed?
      update_counters record, :live_projects
      record.commenters.each{|u| u.update_counters only: [:comments] }
      if record.private?
        Broadcast.where(context_model_id: record.id, context_model_type: 'Project').destroy_all
      end
    end
  end

  def before_create record
    record.reset_counters assign_only: true
  end

  def before_save record
    if record.private_changed? and record.public?
      record.made_public_at = Time.now
    end
  end

  def before_update record
    if record.assignment_id_changed? and record.assignment_id.present? and record.issues.empty?
      issue = record.issues.new title: 'Feedback'
      issue.type = 'Feedback'
      issue.user_id = 0
      issue.save
    end

    if record.private_changed?
      update_counters record, :live_projects
      record.commenters.each{|u| u.update_counters only: [:comments] }
      if record.private?
        Broadcast.where(context_model_id: record.id, context_model_type: 'Project').destroy_all
        Broadcast.where(project_id: record.id).destroy_all
      end
    end

    if (record.changed && %w(assignment_id name cover_image one_liner tech_tags product_tags made_public_at license)).any? or record.tech_tags_string_changed? or product_tags_string_changed?
      Cashier.expire "project-#{record.id}-teaser"
    end
  end

  private
    def update_counters record, type
      record.users.each{ |u| u.update_counters only: [type].flatten }
    end
end