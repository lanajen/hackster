arduino = Platform.find_by_user_name 'arduino'
out = "name,public?,state,url\r\n"
pr=Project.joins(:platform_tags).where(tags: { name: 'Arduino' }).includes(hardware_parts: :platform).each do |p|
  yes = false
  p.hardware_parts.each do |pa|
    if pa.platform == arduino and pa.approved?
      yes = true
      break
    end
  end
  unless yes
    name = ''
    p.hardware_parts.each do |pa|
      if pa.name =~ /(a|A)rduino/
        name = pa.name
      end
    end
    out << "\"#{p.name}\",#{p.publyc},#{p.workflow_state},https://www.hackster.io/#{p.uri},#{name}\r\n"
  end
end; nil
puts out