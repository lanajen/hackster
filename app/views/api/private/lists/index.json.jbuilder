json.lists @lists do |list|
  json.partial! 'list', list: list
  json.isInitiallyChecked @project_lists.include?(list.id)
end