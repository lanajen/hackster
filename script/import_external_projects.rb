# website,name,one_liner,cover_image,guest_name
# csv_text = ""

require 'csv'

tech = 'BeagleBoard'

csv = CSV.parse(csv_text, headers: true)
csv.each do |row|
  hash = {}
  row.to_hash.each{|k,v| hash[k] = v.try(:strip) }
  p = Project.new(hash.except('cover_image'))
  i = CoverImage.new
  i.skip_file_check!
  i.remote_file_url = hash['cover_image']
  p.cover_image = i
  p.external = true
  p.tech_tags_string = tech
  p.save
end