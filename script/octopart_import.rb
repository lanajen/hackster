csv_text = ""

require 'csv'

csv = CSV.parse(csv_text, headers: true)
errors=[]
csv.each do |row|
  hash = {}
  row.to_hash.each{|k,v| hash[k] = v.try(:strip) }
  p = HardwarePart.new
  p.name = hash['description']
  p.product_tags_string = hash['category']
  p.mpn = hash['mpn']
  p.store_link = hash['ext_url'].presence || hash['octo_url']
  p.unit_price = hash['cost'].gsub(/\$/, '') if hash['cost'] != 'Loading...'
  p.build_image
  p.image.remote_file_url = hash['image_url']
  if platform = Platform.find_by_full_name(hash['manufacturer'])
    p.platform = platform
  else
    p.generic = true
  end
  p.workflow_state = 'approved'
  begin
    errors << [p, 'save'] unless p.save
  rescue => e
    errors << [p, e]
  end
end