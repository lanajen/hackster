json.platform do
  json.name @platform.name
  json.url platform_home_url(@platform)
  json.projects do
    json.array! @projects do |col|
      project = col.project

      json.name project.name
      json.url project_url(project, subdomain: ENV['SUBDOMAIN'])
      json.embed_url project_embed_url(project)
      json.cover_image_url project.cover_image.try(:imgix_url, :cover_thumb)
      json.one_liner project.one_liner
      json.author_names project.users.map(&:name).to_sentence
      json.views project.impressions_count
      json.comments project.comments_count
      json.respects project.respects_count
    end
  end
end