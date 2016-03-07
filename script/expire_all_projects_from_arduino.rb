id = 9110
p = Project.find id

keys = []
p.respecting_users.each{|u| keys << "user-#{u.id}-thumb" }
keys << "project-#{id}-respects"
puts keys.to_s
Cashier.expire *keys

platform = Platform.find_by_user_name 'arduino'
platform.project_collections.references(:project).includes(:project).visible.each do |col|
  p = col.project
  keys = []
  p.respecting_users.each{|u| keys << "user-#{u.id}-thumb" }
  p.replicated_users.each{|u| keys << "user-#{u.id}-thumb" } if p.respond_to? :replicated_users
  keys << "project-#{p.id}-respects"
  keys << "project-#{p.id}-replications"
  keys << "project-#{p.id}-thumb"
  keys << "project-#{p.id}-other"
  puts keys.to_s
  Cashier.expire *keys
end;nil
