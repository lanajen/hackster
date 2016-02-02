json.id project.id
json.name project.name
json.type project.type
json.one_liner project.one_liner
json.tags project.product_tags_string
json.url project_url(project, subdomain: ENV['SUBDOMAIN'])
json.cover_image_url project.decorate.cover_image(:cover_thumb)
json.authors project.users.includes(:avatar) do |user|
  json.partial! 'api/private/users/user', user: user
end
json.communities project.groups.where.not(groups: { type: 'Event' }).includes(:avatar).order(full_name: :asc) do |community|
  json.partial! 'api/private/communities/community', community: community
end