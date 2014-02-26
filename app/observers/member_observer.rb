class MemberObserver < ActiveRecord::Observer
  def after_create record
    # only send invitation if group is a community and the membership has an
    # invitation pending and the user is not being invited
    if (record.group.is? :community or record.group.is? :promotion) and record.invitation_pending? and !
      record.user.try(:invited_to_sign_up?)
      BaseMailer.enqueue_email 'new_community_invitation',
        { context_type: :membership, context_id: record.id }
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

  def after_save record
    update_counters record
  end

  def after_destroy record
    update_counters record
  end

  private
    def update_counters record
      record.user.update_counters only: [:projects, :live_projects] if
        record.group and record.group.is? :team
    end
end