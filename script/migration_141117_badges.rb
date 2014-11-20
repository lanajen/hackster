User.where.not(user_name: nil).where(invitation_token: nil).order(:id).each do |user|
  puts user.id.to_s
  begin
    Rewardino::Badge.all.each do |badge|
      user.evaluate_badge badge
    end
  # rescue => e
  #   raise e.message
  #   puts 'failed ' + user.id.to_s
  end
  user.update_counters only: [:badges_green, :badges_bronze,
    :badges_silver, :badges_gold]
end

User.where.not(user_name: nil).where(invitation_token: nil).invitation_accepted_or_not_invited.update_all("subscriptions_mask = (subscriptions_mask + #{2**User::SUBSCRIPTIONS.keys.index('new_badge')})")