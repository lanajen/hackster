require 'ffaker'

group = Group.create

10.times do
  user = User.new
  user.full_name    = FFaker::Name.name
  user.password = (0...8).map{(65+rand(26)).chr}.join
  user.city    = FFaker::Address.city
  user.country = 'United States'
  user.user_name = FFaker::Internet.user_name.gsub(/[^a-z_]/, '_')
  user.email = user.email_confirmation = "#{user.user_name}@example.com"
  user.facebook_link = "www.facebook.com/#{user.user_name}"
  user.linked_in_link = "www.linkedin.com/in/#{user.user_name}"
  user.twitter_link = "www.twitter.com/#{user.user_name}"
  user.mini_resume = FFaker::HipsterIpsum.paragraph[0..159]
  user.build_avatar
  user.avatar.skip_file_check!
  user.avatar.remote_file_url = 'http://lorempixel.com/200/200/people'
  user.interest_tags_string = FFaker::HipsterIpsum.words(3).join(',')
  user.skill_tags_string = FFaker::HipsterIpsum.words(3).join(',')
  user.save
  Member.create!(user: user, group: group)
end

users = User.pluck(:id)
10.times do
  project = Project.new
  3.times do
    image = project.images.new
    image.skip_file_check!
    image.remote_file_url = 'http://lorempixel.com/640/480/technics'
  end
  project.name = FFaker::Lorem.words(3).join(' ')
  project.description = FFaker::Lorem.paragraph
  (rand(3)+1).times do
    project.team_members.new user_id: users.sample, group: group
  end
  project.start_date = rand(100).months.ago
  project.website = FFaker::Internet.http_url
  project.product_tags_string = FFaker::HipsterIpsum.words(3).join(',')
  project.save
end

Project.index.import Project.all
User.index.import User.all
