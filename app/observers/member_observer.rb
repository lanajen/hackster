class MemberObserver < ActiveRecord::Observer
  def after_commit_on_create record
    # only send invitation if group is a community and the membership has an
    # invitation pending and the user is not being invited
    if (record.group.is? :community or record.group.is? :promotion or record.group.is? :event or record.group.is? :platform) and record.invitation_pending? and !record.user.try(:invited_to_sign_up?)
      BaseMailer.enqueue_email 'new_community_invitation',
        { context_type: :membership, context_id: record.id }
    elsif record.group.is? :team
      project = record.group.projects.first
      if record.request_pending?
        BaseMailer.enqueue_email 'new_request_to_join_team',
          { context_type: :membership_request, context_id: record.id }
      end
    elsif record.group.is? :event and record.request_pending?
      BaseMailer.enqueue_email 'new_request_to_join_event',
        { context_type: :membership_request, context_id: record.id }
    end
  end

  def after_create record
    if record.group.is? :team
      project = record.group.projects.first
      unless record.request_pending?
        expire_projects record
        record.user.broadcast :new, record.id, 'Member', project.id if project and project.public?
      end
    elsif record.group.is? :platform
      Cashier.expire "user-#{record.user_id}-sidebar", "user-#{record.user_id}-thumb", "platform-#{record.group_id}-sidebar"
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
    if record.group.is?(:team) and record.approved_to_join_changed?
      if record.approved_to_join
        record.group.touch
        BaseMailer.enqueue_email "request_to_join_#{record.group.class.name.underscore}_accepted",
          { context_type: :membership, context_id: record.id }
        expire_projects record
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
    expire_projects record if record.group.is?(:team)
  end

  private
    def expire_projects record
      # keys = record.group.projects.map{|p| ["project-#{p.id}-teaser", "project-#{p.id}-thumb"] }.flatten
      # puts "project keys to expire: #{keys.inspect}"
      Cashier.expire "team-#{record.group_id}"
    end

    def update_counters record
      record.user.update_counters only: [:projects, :live_projects] if
        record.group and record.group.is? :team
    end
end