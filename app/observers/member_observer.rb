class MemberObserver < ActiveRecord::Observer
  def after_create record
    # only send invitation if group is a community and the membership has an
    # invitation pending and the user is not being invited
    if (record.group.is? :community or record.group.is? :promotion) and record.invitation_pending? and !
      record.user.try(:invited_to_sign_up?)
      BaseMailer.enqueue_email 'new_community_invitation',
        { context_type: :membership, context_id: record.id }
    end
    if record.group.is? :team
      project = record.group.projects.first
      record.user.broadcast :new, record.id, 'Member', project.id if project and project.public?
    end
    unless record.permission
      record.initialize_permission(true)
      record.save
    end
  end

  def after_initialize record
    record.initialize_permission if record.new_record? and record.group and
      record.group.persisted?
  end

  def after_update record
    if record.approved_to_join_changed? and record.approved_to_join
      # raise 'yo!'
      team = record.group
      team.updated_at = Time.now
      team.save
    end
  end

  def after_save record
    update_counters record
  end

  def after_destroy record
    Broadcast.where(context_model_id: record.id, context_model_type: 'Member').destroy_all
    update_counters record
  end

  private
    def update_counters record
      record.user.update_counters only: [:projects, :live_projects] if
        record.group and record.group.is? :team
    end
end