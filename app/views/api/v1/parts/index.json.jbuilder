json.parts @parts do |part|
  json.partial! 'part', part: part
end
json.page @parts.current_page
json.next_page @parts.next_page
json.total_results @parts.total_entries
json.type params[:human_type] if params[:human_type]
json.q params[:q] if params[:q]