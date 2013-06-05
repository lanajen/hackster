class UserObserver < ActiveRecord::Observer
  def after_create record
    advertise_new_user record unless record.invited?
  end

  def before_update record
    if record.invitation_accepted_at_changed?
      advertise_new_user record
      BaseMailer.enqueue_email 'invite_request_accepted',
        { context_type: :inviter, context_id: record.id }
    elsif (record.changed & %w(user_name mini_resume city country full_name)).any?
      record.broadcast :update, record.id, 'User'
    end
  end

  private
    def advertise_new_user record
      record.broadcast :new, record.id, 'User'
      BaseMailer.enqueue_email 'registration_confirmation',
        { context_type: :user, context_id: record.id } unless record.skip_registration_confirmation
    end
end