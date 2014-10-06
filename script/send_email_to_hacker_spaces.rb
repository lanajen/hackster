i = 0
HackerSpace.where("email IS NOT NULL").where.not("email ILIKE '%googlegroups%'").where.not("email LIKE '%lists.%'").where('created_at < ?', '2014-09-27'.to_date).distinct(:email).order(:id).find_in_batches(batch_size: 100) do |group|
  group.each do |h|
    claim_link = "http://hackster.io/groups/#{h.id}/invitations?token=#{h.invitation_token}&role=team&permission=manage"
    msg = "<p>Hi there,</p>

    <p>This is to let you know that we've added #{h.name} to our global list of hacker spaces: <a href='http://hackster.io/hackerspaces'>hackster.io/hackerspaces</a>.</p>

    <p>We've also created a dedicated page so that members can document and share their projects: <a href='http://hackster.io/h/#{h.user_name}'>hackster.io/h/#{h.user_name}</a>. You can claim it by using this link: <a href='#{claim_link}'>#{claim_link}</a>.</p>

    <p>Questions? Suggestions? Requests? Reply and we'll help you out.</p>

    <p>Cheers,<br>
    Ben and the Hackster.io team</p>"

    message = Message.new(
      message_type: 'generic',
      to_email: h.email,
    )
    message.subject = "#{h.name} is now listed on Hackster.io"
    message.body = msg
    MailerQueue.perform_in i*24.hours, 'generic_message', message.name, message.from_email, message.to_email, message.subject, message.body, message.message_type, message.recipients
    # BaseMailer.enqueue_generic_email(message)
  end
  i = i + 1
end

# HackerSpace.where("email ILIKE '%googlegroups%'").each{|h| h.mailing_list_link = h.email; h.email=nil; h.save }
# HackerSpace.where("email LIKE '%lists.%'").each{|h| h.mailing_list_link = h.email; h.email=nil; h.save }

# HackerSpace.where(email: %w(xda-owner@audienciazero.org brmlab-bounces@brmlab.cz sis-afk-owner@bthstudent.se hsmr-bounces@lists.metarheinmain.de)).each{|h| h.mailing_list_link = h.email; h.email=nil; h.save }