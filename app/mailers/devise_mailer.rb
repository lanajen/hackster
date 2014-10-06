class DeviseMailer < BaseMailer
  def confirmation_instructions(record, token, opts={})
    user_email 'confirmation_instructions', record, token, opts
  end

  def confirmation_instructions_simplified_signup(record, token, opts={})
    user_email 'confirmation_instructions_simplified_signup', record, token, opts
  end

  def invitation_instructions(record, token, opts={})
    type = record.invited_by.present? ? 'invitation_instructions' : 'invite_granted'
    enqueue_devise_email type, { context_type: :invited, context_id: record.id }, opts.merge(token: token)
  end

  def invitation_instructions_with_event_member(record, token, opts={})
    invitation_instructions_with_member(record, token, opts={})
  end

  def invitation_instructions_with_promotion_member(record, token, opts={})
    invitation_instructions_with_member(record, token, opts={})
  end

  def invitation_instructions_with_tech_member(record, token, opts={})
    invitation_instructions_with_member(record, token, opts={})
  end

  def invitation_instructions_with_hacker_space_member(record, token, opts={})
    invitation_instructions_with_member(record, token, opts={})
  end

  def invitation_instructions_with_member(record, token, opts={})
    enqueue_devise_email 'invitation_instructions_with_member',
      { context_type: :membership, context_id: record.id }, opts.merge(token: token)
  end

  def reset_password_instructions(record, token, opts={})
    user_email 'password_lost', record, token, opts
  end

  private
    def user_email template, record, token, opts={}
      enqueue_devise_email template, { context_type: :user, context_id: record.id }, opts.merge(token: token)
    end
end