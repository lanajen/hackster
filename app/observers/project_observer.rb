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
    if record.external
      record.slug_histories.destroy_all
    else
      SlugHistory.update_history_for record.id
    end

    record.teches = Tech.joins(:tech_tags).references(:tags).where("LOWER(tags.name) IN (?)", record.tech_tags.map{|t| t.name.downcase }) if record.public? and !record.hide or (record.external and record.approved != false)
  end

  def after_update record
    if record.private_changed?
      update_counters record, [:live_projects]
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
    if record.collection_id_changed? and record.assignment and record.issues.empty?
      issue = record.issues.new title: 'Feedback'
      issue.type = 'Feedback'
      issue.user_id = 0
      issue.save
    end

    if record.private_changed?
      update_counters record, [:live_projects]
      record.commenters.each{|u| u.update_counters only: [:comments] }
      if record.private?
        delete_group_relations record
        Broadcast.where(context_model_id: record.id, context_model_type: 'Project').destroy_all
        Broadcast.where(project_id: record.id).destroy_all
      end
    end

    if record.approved_changed? and record.approved == false
      delete_group_relations record
    end

    if (record.changed & %w(collection_id name cover_image one_liner tech_tags product_tags made_public_at license guest_name)).any? or record.tech_tags_string_changed? or record.product_tags_string_changed?
      Cashier.expire "project-#{record.id}-teaser"
    end

    if (record.changed & %w(name guest_name cover_image one_liner private wip start_date slug respects_count comments_count)).any?
      Cashier.expire "project-#{record.id}-thumb"
    end

    if (record.changed & %w(website)).any?
      Cashier.expire "project-#{record.id}-thumb-external"
    end
  end

  private
    def delete_group_relations record
      GroupRelation.where(project_id: record.id).destroy_all
    end

    def update_counters record, type
      record.users.each{ |u| u.update_counters only: [type].flatten }
    end
end