json.part_mpn params[:part_mpn] if params[:part_mpn]

if params[:only_count]
  json.total_results @count
else
  json.projects @projects do |project|
    json.partial! 'project', project: project
  end
  json.page @projects.current_page
  json.next_page @projects.next_page
  json.total_results @projects.total_entries
end

json.url @url if @url and params[:only_count]