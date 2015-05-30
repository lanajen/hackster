PartJoin.all.each do |join|
  next unless join.partable.project
  PartJoin.create part_id: join.part_id, comment: join.comment, quantity: join.quantity, partable_type: 'Project', partable_id: join.partable.widgetable_id, total_cost: join.total_cost, position: join.position
end