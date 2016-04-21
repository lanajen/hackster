class ProjectJsonDecorator < BaseJsonDecorator
  def node
    node = hash_for(%w(id communities name authors project_url authors))
    node[:id] = model.id
    node[:name] = model.name
    node[:url] = project_url(model, subdomain: ENV['SUBDOMAIN'])
    node[:communities] = model.groups.where.not(groups: { type: 'Event' }).includes(:avatar).order(full_name: :asc) do |community|
      json.partial! 'api/private/communities/community', community: community
    end
    node[:authors] = json.authors project.users do |user|
      node[:authors].id user.id
      node[:authors].name user.name
      node[:authors].url user_url(user, subdomain: ENV['SUBDOMAIN'])
    end
  end
end

#THIS IS NOT WORKING
