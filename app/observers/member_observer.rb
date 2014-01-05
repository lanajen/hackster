class MemberObserver < ActiveRecord::Observer
  def after_create record
    # only send invitation if group is a community and the membership has an
    # invitation pending and the user is not being invited
    if record.group.is? :community and record.invitation_pending? and !record.user.try(:invited_to_sign_up?)
      BaseMailer.enqueue_email 'new_community_invitation',
        { context_type: :membership, context_id: record.id }
    end
  end

  def after_initialize record
    record.initialize_permission
  end

  def after_save record
    update_counters record
  end

  def after_destroy record
    update_counters record
  end

  def before_create record
    record.initialize_permission(true)
  end

  private
    def update_counters record
      record.user.update_counters only: [:projects, :live_projects] if record.group and record.group.is? :team

      record.group.projects.each{ |p| p.update_slug! } if record.group and record.group.is? :team
    end
end