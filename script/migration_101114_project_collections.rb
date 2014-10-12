GroupRelation.all.each do |rel|
  p = ProjectCollection.new
  p.project_id = rel.project_id
  p.collectable_type = 'Group'
  p.collectable_id = rel.group_id
  p.workflow_state = rel.workflow_state
  p.save
end

Assignment.pluck(:id).each do |id|
  Project.where(collection_id: id).each do |project|
    p = ProjectCollection.new
    p.project_id = project.id
    p.collectable_type = 'Assignment'
    p.collectable_id = id
    p.save
  end
end

Event.pluck(:id).each do |id|
  Project.where(collection_id: id).each do |project|
    p = ProjectCollection.new
    p.project_id = project.id
    p.collectable_type = 'Group'
    p.collectable_id = id
    p.save
  end
end

# next steps:
# - remove collection_id from projects
# - move assignment_submitted_at from projects to project_collections
# - remove group_relations table