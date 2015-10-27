json.projects @projects do |project|
  json.id project.id
  json.name project.name
  json.url project_url(project, subdomain: 'www')
  json.authors project.users do |user|
    json.id user.id
    json.name user.name
    json.url user_url(user, subdomain: 'www')
  end
  json.views project.impressions.where("impressions.created_at > ? AND impressions.created_at < ?", @range_start, @range_end).group("DATE(impressions.created_at)").order("date_impressions_created_at").count do |date, count|
    json.date date
    json.count count
  end
end

json.range_start @range_start
json.range_end @range_end

json.page safe_page_params || 1
json.total_pages @projects.total_pages