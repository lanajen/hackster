json.q params[:q]
json.total_results @results.respond_to?(:total_count) ? @results.total_count : 0

unless params[:only_count]
  json.facets @facets
  json.max @max
  json.offset @offset
  json.results @results
end