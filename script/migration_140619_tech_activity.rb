Tech.find_each do |tech|
  projects = Project.joins(:tech_tags).references(:tags).where("LOWER(tags.name) IN (?)", tech.tech_tags.map{|t| t.name.downcase })
  projects.each do |project|
    GroupRelation.create project_id: project.id, group_id: tech.id, created_at: project.created_at
  end
end

User.where.not(user_name: nil).invitation_accepted_or_not_invited.update_all("subscriptions_mask = (subscriptions_mask + #{2**User::SUBSCRIPTIONS.keys.index('follow_tech_activity')})")