# full_name,country,state,city,website_link
# csv_text = ""

require 'csv'

csv = CSV.parse(csv_text, headers: true)
errors=[]
csv.each do |row|
  hash = {}
  row.to_hash.each{|k,v| hash[k] = v.try(:strip) }
  next unless p = Part.find_by_id(hash['id'])
  p.vendor_sku = hash['vendor_sku']
  p.vendor_link = hash['vendor_link']
  begin
    errors << p unless p.save
  rescue
    errors << p
  end
end