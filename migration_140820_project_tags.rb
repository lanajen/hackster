Project.all.each do |p|
  p.tech_tags_string_from_tags
  p.product_tags_string_from_tags
  p.save
end