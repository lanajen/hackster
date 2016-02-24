json.parts @parts[:models] do |part|
  json.partial! 'part', part: part
end
json.page @parts[:page]
json.next_page @parts[:max] > @parts[:total_size] ? @parts[:page] : nil
json.total_results @parts[:total_size]
json.type params[:human_type] if params[:human_type]
json.q params[:q] if params[:q]