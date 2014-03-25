class MemberObserver < ActiveRecord::Observer
  def after_create record
    # only send invitation if group is a community and the membership has an
    # invitation pending and the user is not being invited
    if (record.group.is? :community or record.group.is? :promotion) and record.invitation_pending? and !
      record.user.try(:invited_to_sign_up?)
      BaseMailer.enqueue_email 'new_community_invitation',
        { context_type: :membership, context_id: record.id }
    elsif record.group.is? :team
      project = record.group.projects.first
      if record.request_pending?
        BaseMailer.enqueue_email 'new_request_to_join_team',
          { context_type: :membership_request, context_id: record.id }
      else
        record.user.broadcast :new, record.id, 'Member', project.id if project and project.public?
      end
    elsif record.group.is? :event
      BaseMailer.enqueue_email 'new_request_to_join_event',
        { context_type: :membership_request, context_id: record.id }
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
    if record.approved_to_join_changed?
      if record.approved_to_join
        record.group.touch
        BaseMailer.enqueue_email "request_to_join_#{record.group.class.name.underscore}_accepted",
          { context_type: :membership, context_id: record.id }
      else
        record.update_column :group_roles_mask, 0
        record.permission.destroy
        # BaseMailer.enqueue_email 'request_to_join_team_rejected',
          # { context_type: :membership, context_id: record.id }
      end
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