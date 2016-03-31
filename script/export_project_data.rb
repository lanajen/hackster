
headers="project_id,project_url,project_name,impressions_count,respects_count,comments_count,author_ids,date_published,components_count,tools_count,apps_count,has_schematics,has_code,story_length,platforms_count,contest_entry,tags,template,content_type".split(',')

rows=[headers]
BaseArticle.indexable.last_public.limit(1000).each do |project|
  row=[]
  row << project.id
  row << "https://www.hackster.io/#{project.uri}"
  row << project.name
  row << project.impressions_count
  row << project.respects_count
  row << project.comments_count
  row << project.users.pluck(:id).join(',')
  row << project.made_public_at
  row << (project.respond_to?(:hardware_parts) ? project.hardware_parts.count : 'N/A')
  row << (project.respond_to?(:tool_parts) ? project.tool_parts.count : 'N/A')
  row << (project.respond_to?(:software_parts) ? project.software_parts.count : 'N/A')
  row << (project.type == 'Project' ? project.widgets.where(type: %w(SchematicWidget SchematicFileWidget)).any? : 'N/A')
  row << (project.type == 'Project' ? project.widgets.where(type: %w(CodeWidget CodeRepoWidget)).any? : 'N/A')
  row << project.decorate.story.try(:size) || 0
  row << project.visible_platforms.count
  row << (project.type == 'Project' ? project.challenge_entries.count : 'N/A')
  row << project.product_tags_string
  row << project.type
  row << project.content_type
  rows << row
end

csv_text = rows.map do |row|
  row.map{|v| "\"#{v}\"" }.join(',')
end.join("\r\n")