# website,name,one_liner,cover_image,guest_name
# csv_text = ""

require 'csv'

platform = 'Espruino'

csv = CSV.parse(csv_text, headers: true)
projects=[]
csv.each do |row|
  hash = {}
  row.to_hash.each{|k,v| hash[k] = v.try(:strip) }
  p = Project.new(hash.except('cover_image'))
  i = CoverImage.new
  i.skip_file_check!
  i.remote_file_url = hash['cover_image']
  p.cover_image = i
  p.external = true
  p.platform_tags_string = platform
  projects << p unless p.save
end