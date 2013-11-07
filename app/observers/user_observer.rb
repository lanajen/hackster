class UserObserver < ActiveRecord::Observer
  def after_create record
    unless record.invited?
      advertise_new_user record
      record.create_reputation
    end
  end

  def after_invitation_accepted record
    invite = record.find_invite_request
    invite.project.team_members.create(user_id: record.id) if invite and invite.project
  end

  def before_update record
    if record.invitation_accepted_at_changed?
      advertise_new_user record
      BaseMailer.enqueue_email 'invite_request_accepted',
        { context_type: :inviter, context_id: record.id }
      record.build_reputation unless record.reputation
    elsif record.accepted_or_not_invited? and (record.changed & %w(user_name mini_resume city country full_name)).any?
      record.broadcast :update, record.id, 'User'
    end
    record.interest_tags_count = record.interest_tags_string.split(',').count
    record.skill_tags_count = record.skill_tags_string.split(',').count
  end

  def before_create record
    record.reset_counters assign_only: true
  end

  private
    def advertise_new_user record
      record.broadcast :new, record.id, 'User'
      BaseMailer.enqueue_email 'registration_confirmation',
        { context_type: :user, context_id: record.id } unless record.skip_registration_confirmation
    end
end