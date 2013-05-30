class DeviseMailer < Devise::Mailer
  def confirmation_instructions(record)
    BaseMailer.enqueue_email 'confirmation_instructions', { context_type: :user, context_id: record.id }
  end

  def invitation_instructions(record)
    type = record.invited_by.present? ? 'invitation_instructions' : 'invite_request_accepted'
    BaseMailer.enqueue_email type, { context_type: :user, context_id: record.id }
  end

  def reset_password_instructions(record)
    BaseMailer.enqueue_email 'password_lost', { context_type: :user, context_id: record.id }
  end
end