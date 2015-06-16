User.all.each do|p|
  p.hproperties = {}
  p.properties.each{|k,v| p.hproperties[k] = v }
  p.update_attribute :hproperties, p.hproperties
  p.update_counters
end