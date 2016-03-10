json.id project.id
json.name project.name
json.template project.type
json.content_type project.content_type
json.one_liner project.one_liner
json.tags project.product_tags_string
json.url project_url(project, subdomain: ENV['SUBDOMAIN'])
json.cover_image_url project.decorate.cover_image(:cover_thumb)
json.published_at project.made_public_at
json.stats do
  json.impressions project.impressions_count
  json.comments project.comments_count
  json.respects project.respects_count
end
json.authors project.users.includes(:avatar) do |user|
  json.partial! 'api/private/users/user', user: user
end
json.communities project.groups.where.not(groups: { type: 'Event' }).includes(:avatar).order(full_name: :asc) do |community|
  json.partial! 'api/private/communities/community', community: community
end