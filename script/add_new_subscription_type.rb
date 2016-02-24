User.where.not(user_name: nil).where(invitation_token: nil).invitation_accepted_or_not_invited.update_all("subscriptions_masks = subscriptions_masks || ('email'=>CAST(CAST(subscriptions_masks -> 'email' AS INTEGER) + #{2**User::SUBSCRIPTIONS[:email].keys.index('contest_reminder')} AS VARCHAR))::hstore").where.not(subscriptions_masks: nil)

User.where(id: 1).update_all("subscriptions_masks = subscriptions_masks || (\"email\"=>CAST((1 + #{2**User::SUBSCRIPTIONS[:email].keys.index('contest_reminder')}) AS VARCHAR))::hstore")

begin
  User.without_subscription('email', 'contest_reminder').user_name_set.invitation_accepted_or_not_invited.not_hackster.order(:id).find_each do |u|
    @user_id = u.id
    u.email_subscriptions = u.email_subscriptions + ['contest_reminder']
    u.web_subscriptions = u.web_subscriptions + ['contest_reminder']
    u.save
  end
rescue => e
  'failed: user_id: ' + @user_id.to_s + ' ' + e.inspect
end