ActiveRecord::Base.transaction do
  TeamMember.all.each do |m|
    project = m.project
    user = m.user
    next unless project and user
    unless team = project.team
      team = project.create_team
      project.save
    end
    team.users << user unless user.in? team.users
  end
end

Broadcast.where(broadcastable_type: 'Account').update_all(broadcastable_type: 'User')