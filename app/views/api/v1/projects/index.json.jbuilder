json.part_mpn params[:part_mpn] if params[:part_mpn] and params[:platform_user_name]

if params[:only_count]
  json.total_results @count
else
  if @collections
    json.projects @collections do |col|
      json.partial! 'project', project: col.project
      json.collection_status col.workflow_state
      json.collection_added_at col.created_at
    end
    json.page @collections.current_page
    json.next_page @collections.next_page
    json.total_results @collections.total_entries
  else
    json.projects @projects do |project|
      json.partial! 'project', project: project
    end
    json.page @projects.current_page
    json.next_page @projects.next_page
    json.total_results @projects.total_entries
  end
end

json.url @url if @url and params[:only_count]