Platform.find_each do |platform|
  projects = Project.joins(:platform_tags).references(:tags).where("LOWER(tags.name) IN (?)", platform.platform_tags.map{|t| t.name.downcase })
  projects.each do |project|
    GroupRelation.create project_id: project.id, group_id: platform.id, created_at: project.created_at
  end
end

Respect.where(respecting_type: 'Group').each do |respect|
  GroupRelation.where(project_id: respect.project_id, group_id: respect.respecting_id).first.feature!
end

User.where.not(user_name: nil).invitation_accepted_or_not_invited.update_all("subscriptions_mask = (subscriptions_mask + #{2**User::SUBSCRIPTIONS.keys.index('follow_platform_activity')})")