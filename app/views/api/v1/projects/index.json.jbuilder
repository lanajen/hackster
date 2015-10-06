json.projects @projects do |project|
  json.partial! 'project', project: project
end
json.page @projects.current_page
json.next_page @projects.next_page
json.total_results @projects.total_entries
json.q params[:q] if params[:q]