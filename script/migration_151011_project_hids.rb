Project.where(hid: nil).find_each{|p| p.update_column :hid, SecureRandom.hex(3) }

Project.group(:hid).having("count(*) > 1").count.each do |hid, count|
  Project.where(hid: hid).each do |project|
    project.generate_hid
    project.save
  end
end