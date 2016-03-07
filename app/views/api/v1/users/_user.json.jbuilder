json.id user.id
json.name user.name
json.user_name user.user_name
json.url user_url(user, subdomain: ENV['SUBDOMAIN'])
json.avatar_url user.decorate.avatar
json.bio user.mini_resume
json.city user.city
json.country user.country
json.interests user.interest_tags_cached
json.skills user.skill_tags_cached
json.stats do
  json.impressions user.impressions_count
  json.projects user.projects_count
  json.followers user.followers_count
end