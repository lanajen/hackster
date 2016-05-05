json.id project.id
json.hid project.hid
json.name project.name
json.template project.type
json.content_type project.content_type
json.one_liner project.one_liner
json.license do
  if project.license
    json.name project.license.name
    json.url project.license.url
    json.abbr project.license.abbr
  end
end
json.tags project.product_tags_cached
json.url project_url(project, subdomain: ENV['SUBDOMAIN'])
json.cover_image_url project.decorate.cover_image(:cover_thumb)
json.created_at project.created_at
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
if @with_details
  if project.story_json.nil?
    json.story_html project.decorate.description
  else
    json.story_json StoryJsonJsonDecorator.new(project.story_json).to_json
  end
  json.products project.part_joins.includes(part: [:image, :platform]) do |part_join|
    part = part_join.part
    json.id part.id
    json.name part.name
    json.type part.identifier
    if platform = part.platform
      json.platform do
        json.id platform.id
        json.name platform.name
        json.avatar_url platform.decorate.avatar(:thumb)
        json.url group_url(platform, subdomain: 'www')
      end
    end
    json.quantity part_join.quantity
    json.comment part_join.comment
    if part.has_own_page?
      json.url part_url(part, subdomain: 'www')
      json.image_url part.decorate.image(:thumb)
    end
  end
  json.attachments project.widgets.where.not(type: 'CreditsWidget') do |w|
    json.name w.name
    json.type w.type
    json.template w.identifier
    if w.respond_to?(:comment)
      json.comment w.comment
    end
    if w.respond_to?(:document) and document = w.document
      json.file do
        json.name document.file_name
        json.url document.file_url
      end
    end
    if w.respond_to?(:url)
      json.url w.url
    end
    if w.type == 'CodeWidget'
      json.raw_code w.raw_code
      json.formatted_code w.formatted_content
      json.language w.language
      json.binary w.binary?
    end
  end
end