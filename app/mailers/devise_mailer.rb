class DeviseMailer < ActionMailer::Base
  def confirmation_instructions(record, token, opts={})
    user_email 'confirmation_instructions', record, token, opts
  end

  def confirmation_instructions_simplified_signup(record, token, opts={})
    user_email 'confirmation_instructions_simplified_signup', record, token, opts
  end

  def invitation_instructions(record, token, opts={})
    template = record.invited_by.present? ? 'invitation_instructions' : 'invite_granted'
    user_email template, record, token, opts.merge(context_type: :invited)
  end

  def invitation_instructions_with_member(record, token, opts={})
    user_email 'invitation_instructions_with_member', record, token, opts.merge(context_type: :membership)
  end

  def reset_password_instructions(record, token, opts={})
    user_email 'password_lost', record, token, opts
  end

  private
    def user_email template, record, token, opts={}
      self.message.perform_deliveries = false
      context_type = opts.delete(:context_type) || :user
      NotificationCenter.perform_async 'notify_via_email', nil, context_type, record.id, template, opts
    end
end