Platform.all.each do|p|
  p.cta_link = (p.buy_link.presence || p.crowdfunding_link.presence || p.download_link.presence)
  p.update_attribute :cta_link, p.cta_link
end

Group.all.each do|p|
  p.hproperties = {}
  p.properties.each{|k,v| p.hproperties[k] = v }
  p.update_attribute :hproperties, p.hproperties
end