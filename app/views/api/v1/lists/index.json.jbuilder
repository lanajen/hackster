json.lists @lists do |list|
  json.id list.id
  json.name list.name
  json.userName list.user_name
  json.isInitiallyChecked @project_lists.include?(list.id)
end