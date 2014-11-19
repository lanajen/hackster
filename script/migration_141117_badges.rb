green_badges = Rewardino::Badge.by_level :green
silver_badges = %w(project_respected profile_followed project_viewed)
User.where.not(user_name: nil).where(invitation_token: nil).each do |user|
  puts user.id.to_s
  begin
    green_badges.each do |badge|
      user.evaluate_badge badge
    end
    silver_badges.each do |badge|
      user.evaluate_badge badge
    end
  rescue
    puts 'failed ' + user.id.to_s
  end
  user.update_counters only: [:badges, :badges_green, :badges_silver]
end

User.where.not(user_name: nil).where(invitation_token: nil).invitation_accepted_or_not_invited.update_all("subscriptions_mask = (subscriptions_mask + #{2**User::SUBSCRIPTIONS.keys.index('new_badge')})")