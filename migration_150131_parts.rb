errors = []
Part.find_each do |part|
  part_join = PartJoin.new(
    partable_id: part.partable_id,
    partable_type: part.partable_type,
    position: part.position || 0,
    quantity: part.quantity,
    comment: part.comment,
    total_cost: part.total_cost,
    part_id: part.id
  )
  errors << part_join unless part_join.save

  if part.description.present?
    part.name = if part.name.present?
      part.name + ' ' + part.description
    else
      part.description
    end
    part.save
  end
end



# below is just draft notes for the digikey import

parts=Part.joins("inner join widgets on parts.partable_id = widgets.id").joins("inner join projects on widgets.widgetable_id = projects.id").where("widgets.widgetable_type = 'Project'").where("projects.private = 'f'").where("parts.description <> '' AND parts.description IS NOT NULL").order(:id)

#.where("parts.vendor_link = '' or parts.vendor_link IS NULL")

#parts.each{|p| puts p.description };nil

out = "id,description,mpn,vendor_name,project_url,vendor_link,vendor_sku\r\n"
parts.each do |part|
  out << "#{part.id},"
  out << "\"#{part.description.chars.select(&:ascii_only?).join}\","
  out << "#{part.mpn},"
  out << "#{part.vendor_name},"
  out << "http://www.hackster.io/projects/#{part.partable.widgetable_id},"
  out << "#{part.vendor_link},"
  out << "#{part.vendor_sku}\r\n"
end
puts out


parts=Part.joins("inner join widgets on parts.partable_id = widgets.id").joins("inner join projects on widgets.widgetable_id = projects.id").where("widgets.widgetable_type = 'Project'").where("projects.private = 'f'").where("parts.description <> '' AND parts.description IS NOT NULL").where("parts.vendor_link = '' or parts.vendor_link is null").order(:id)

errors = []
parts.each do |part|
  begin
    puts part.id.to_s
    part.search_on_octopart
    errors << part unless part.save
  #rescue => e
   # errors << [part, e]
  end
end