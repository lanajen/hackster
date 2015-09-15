# cohort analysis to calculate retention rates
# cohorts span 7 days
# how many have come back from the day they signed up to now

out = []
start_date = 2.months.ago

while start_date < Time.now
  cohort = User.where("created_at > ? AND created_at < ?", start_date, start_date + 7.days).not_hackster.count
  retained = UserActivity.joins(:user).where("users.created_at > ? AND users.created_at < ?", start_date, start_date + 7.days).where("user_activities.created_at > ?", start_date + 7.days).group(:user_id).count.size
  pct = cohort.zero? ? 0 : ((retained.to_f / cohort) * 100).round(2)
  out << [cohort, retained, pct]
  start_date += 7.days
end

out


# how many come back 23 days to 30 days after signing up? => active users
# cohorts span 24 hours

out = []
total_cohort = 0
total_retained = 0
start_date = 60.days.ago

while start_date < 30.days.ago
  cohort = User.where("created_at > ? AND created_at < ?", start_date, start_date + 1.day).not_hackster.count
  retained = UserActivity.joins(:user).where("users.created_at > ? AND users.created_at < ?", start_date, start_date + 1.day).where("user_activities.created_at > ? AND user_activities.created_at < ?", start_date + 23.days, start_date + 30.days).group(:user_id).count.size
  pct = cohort.zero? ? 0 : ((retained.to_f / cohort) * 100).round(2)
  out << [cohort, retained, pct]
  total_cohort += cohort
  total_retained += retained
  start_date += 1.day
end

out
((total_retained.to_f / total_cohort) * 100).round(2)