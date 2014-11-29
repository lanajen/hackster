Project.all.each do |p|
  p.platform_tags_string_from_tags
  p.product_tags_string_from_tags
  p.save
end