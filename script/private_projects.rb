out = "email,name,project_name,project_link,creation_date,profile_status\r\n"
Project.where(private: true).each do |project|
  author = project.users.first
  if author.nil?
    puts project.name
    next
  end
  out << "\"#{author.email}\","
  out << "\"#{author.name}\","
  out << "\"#{project.name}\","
  out << "\"http://www.hackster.io/projects/#{project.to_param}\","
  out << "\"#{project.created_at}\","
  profile_status = []
  profile_status << 'no websites' if author.websites.blank?
  profile_status << 'no tags' if author.skill_tags.blank?
  profile_status << 'no one liner' if author.mini_resume.blank?
  profile_status << 'no picture' if author.avatar.blank?
  profile_status << 'no location' if author.country.blank? and author.city.blank?
  profile_status = profile_status.to_sentence
  out << "\"#{profile_status}\"\r\n"
end

puts out