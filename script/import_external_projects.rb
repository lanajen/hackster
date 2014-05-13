require 'csv'

# csv_text = ""
tech = 'Intel Galileo'

csv = CSV.parse(csv_text, headers: true)
csv.each do |row|
  p = Project.new(row.to_hash.except('cover_image'))
  i = CoverImage.new
  i.skip_file_check!
  i.remote_file_url = row.to_hash['cover_image']
  p.cover_image = i
  p.external = true
  p.tech_tags_string = tech
  p.save
end

#website,name,one_liner,cover_image,guest_name