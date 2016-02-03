json.id user.id
json.name user.name
json.url user_url(user, subdomain: ENV['SUBDOMAIN'])
json.avatar_url user.decorate.avatar