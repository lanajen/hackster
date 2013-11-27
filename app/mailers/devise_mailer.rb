class DeviseMailer < BaseMailer
  def confirmation_instructions(record, token, opts={})
    @token = token
    enqueue_email 'confirmation_instructions', { context_type: :user, context_id: record.id }
  end

  def invitation_instructions(record, token, opts={})
    @token = token
    type = record.invited_by.present? ? 'invitation_instructions' : 'invite_granted'
    enqueue_email type, { context_type: :user, context_id: record.id }
  end

  def reset_password_instructions(record, token, opts={})
    @token = token
    enqueue_email 'password_lost', { context_type: :user, context_id: record.id }
  end
end