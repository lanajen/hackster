class DeviseMailer < BaseMailer
  def confirmation_instructions(record, token, opts={})
    enqueue_devise_email 'confirmation_instructions', { context_type: :user, context_id: record.id }, opts.merge(token: token)
  end

  def invitation_instructions(record, token, opts={})
    type = record.invited_by.present? ? 'invitation_instructions' : 'invite_granted'
    enqueue_devise_email type, { context_type: :user, context_id: record.id }, opts.merge(token: token)
  end

  def reset_password_instructions(record, token, opts={})
    enqueue_devise_email 'password_lost', { context_type: :user, context_id: record.id }, opts.merge(token: token)
  end
end