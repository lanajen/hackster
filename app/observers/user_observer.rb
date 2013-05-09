class UserObserver < ActiveRecord::Observer
  def after_create record
    record.broadcast :new, record.id, 'User'
    BaseMailer.enqueue_email 'registration_confirmation',
      { context_type: :user, context_id: record.id } unless record.skip_registration_confirmation
    if invite_request = InviteRequest.find_by_email(record.email)
      invite_request.user = record
      invite_request.save
    end
  end

  def after_update record
    if (record.changes.keys - %w(email password roles_mask updated_at)).size > 0
      record.broadcast :update, record.id, 'User'
    end
  end
end