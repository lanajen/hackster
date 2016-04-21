json.projects @projects do |project|
  json.id project.id
  json.name project.name
  json.url project_url(project, subdomain: ENV['SUBDOMAIN'])
  json.communities project.groups.where.not(groups: { type: 'Event' }).includes(:avatar).order(full_name: :asc) do |community|
    json.partial! 'api/private/communities/community', community: community
  end
  json.authors project.users do |user|
    json.id user.id
    json.name user.name
    json.url user_url(user, subdomain: ENV['SUBDOMAIN'])
  end
end

json.range_start @range_start
json.range_end @range_end

json.page safe_page_params || 1
json.total_pages @projects.total_pages