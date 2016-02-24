json.id community.id
json.name community.name
json.url group_url(community, subdomain: ENV['SUBDOMAIN'])
json.logo_url community.decorate.avatar