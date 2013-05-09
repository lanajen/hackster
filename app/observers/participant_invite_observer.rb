class ParticipantInviteObserver < ActiveRecord::Observer
  def after_create record
    email_type = record.issue ? 'with_issue' : 'without_issue'
    BaseMailer.enqueue_email "project_invite_#{email_type}",
      { context_type: :participant_invite, context_id: record.id }
    InviteRequest.create email: record.email, whitelisted: true
  end
end