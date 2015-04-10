
projects = Project.indexable.last_7days.most_respected.limit(15)

projects.includes(:team, :users, :cover_image, :platforms).each do |project|
  url = "http://www.hackster.io/#{project.uri}?ref=newsletter"
  one_liner = project.one_liner.strip
  one_liner += '.' if one_liner !~ /(\.|\!)$/
  authors = (project.users.count == 1 ? project.users.first.name : project.users.map{|u| u.name.split(/ /)[0] }.to_sentence).strip
  platforms = project.platforms.map{|p| "<a href='http://www.hackster.io/#{p.user_name}?ref=newsletter' target='_blank'>#{p.name}</a>" }.to_sentence
  platforms = " With #{platforms}." if platforms.present?

  puts '******_____________******'
  puts 'IMAGE_URL: ' + project.decorate.cover_image(:cover_thumb)
  puts 'URL: ' + url
  puts 'SNIPPET:'
  puts "<h4 style='margin-top:0;margin-bottom:7px;font-size:16px'><a href='#{url}' style='color:#337ab7;text-decoration:none;font-weight:bold' target='_blank'>#{project.name} by #{authors}</a></h4>

  <p style='margin:0;margin-bottom:5px'>#{one_liner}#{platforms}</p>"
  puts '******_____________******'
end;nil