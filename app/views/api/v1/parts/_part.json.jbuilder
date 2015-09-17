json.id part.id
json.name part.name
json.one_liner part.decorate.one_liner_or_description
json.url part_url(part)
json.store_link part.store_link
json.product_page_link part.product_page_link
json.image_url part.decorate.image(:part_thumb)
json.editable part.editable
if platform = part.platform
  json.platform do
    json.id platform.id
    json.name platform.name
    json.logo_url platform.decorate.avatar(:tiny)
  end
end
json.counters do
  # json.impressions part.impressions_count
  json.projects part.projects_count
  json.owners part.owners_count
end