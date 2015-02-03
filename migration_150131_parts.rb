errors = []
Part.order(:id).find_each do |part|
  if part.description.present?
    part.name = if part.name.present?
      (part.name + ' ' + part.description)[0..254]
    else
      part.description
    end
    part.save
  end

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
end



# below is just draft notes for the digikey import

parts=Part.joins("inner join widgets on parts.partable_id = widgets.id").joins("inner join projects on widgets.widgetable_id = projects.id").where("widgets.widgetable_type = 'Project'").joins("inner join part_joins on parts.id = part_joins.part_id").where("projects.private = 'f'").order(:id)

#.where("parts.vendor_link = '' or parts.vendor_link IS NULL")

#parts.each{|p| puts p.description };nil

out = "id,description,mpn,name,project_url,vendor_link\r\n"
parts.each do |part|
  out << "#{part.id},"
  out << "\"#{part.description.try(:chars).try(:select, &:ascii_only?).try(:join)}\","
  out << "#{part.mpn},"
  out << "\"#{part.name}\","
  out << (part.projects.first ? "http://www.hackster.io/projects/#{part.projects.first.id}," : ',')
  out << "#{part.vendor_link}\r\n"
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