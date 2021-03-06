json.id part.id
json.name part.name
json.full_name part.fname if part.respond_to?(:fname)
json.type part.type
json.one_liner part.decorate.one_liner_or_description
json.description part.description
json.tags part.product_tags_string
json.unit_price part.unit_price
json.mpn part.mpn
json.url part_url(part, subdomain: ENV['SUBDOMAIN']) if part.has_own_page?
json.store_link part.store_link
json.product_page_link part.product_page_link
json.get_started_link part.get_started_link
json.documentation_link part.documentation_link
json.libraries_link part.libraries_link
json.datasheet_link part.datasheet_link
json.private part.pryvate
json.status part.workflow_state
json.image_url part.decorate.image(params[:image_size] || :part_thumb)
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