require 'ffaker'

100.times do
  user = User.new
  user.full_name    = Faker::Name.name
  user.password = (0...8).map{(65+rand(26)).chr}.join
  user.email   = user.email_confirmation = Faker::Internet.email
  user.city    = Faker::Address.city
  user.country = 'United States'
  user.user_name = Faker::Internet.user_name.gsub(/[^a-z_]/, '_')
  user.facebook_link = "www.facebook.com/#{user.user_name}"
  user.linked_in_link = "www.linkedin.com/in/#{user.user_name}"
  user.twitter_link = "www.twitter.com/#{user.user_name}"
  user.mini_resume = Faker::HipsterIpsum.paragraph[0..159]
  user.build_avatar
  user.avatar.skip_file_check!
  user.avatar.remote_file_url = 'http://lorempixel.com/200/200/people'
  user.save
  user.interest_tags_string = Faker::HipsterIpsum.words(3).join(',')
  user.skill_tags_string = Faker::HipsterIpsum.words(3).join(',')
  user.publications.create(
    title: Faker::Lorem.sentence(4),
    abstract: Faker::Lorem.paragraph,
    link: Faker::Internet.http_url,
    published_on: rand(100).months.ago
  )
end

10.times do
  project = Project.new
  3.times do
    image = project.images.new
    image.skip_file_check!
    image.remote_file_url = 'http://lorempixel.com/640/480/technics'
  end
  project.name = Faker::Lorem.words(3).join(' ')
  project.description = Faker::Lorem.paragraph
  (rand(3)+1).times do
    project.team_members.new user_id: rand(100)+1, role: %w(CEO CTO Hacker Eng Maker Designer Programmer).sample
  end
  project.start_date = rand(100).months.ago
  project.build_logo
  project.logo.skip_file_check!
  project.logo.remote_file_url = 'http://lorempixel.com/200/200/abstract'
  project.save
  project.product_tags_string = Faker::HipsterIpsum.words(3).join(',')
  project.tech_tags_string = Faker::HipsterIpsum.words(3).join(',')
  project.stages.each do |stage|
    widget = TextWidget.create name: Faker::Lorem.words(3).join(' '), stage_id: stage.id
    widget.content = Faker::HTMLIpsum.p(3, fancy: true, include_breaks: true)
    widget.completion_share = rand 100
    widget.completion_rate = rand 100
    widget.save

    widget = ImageWidget.create name: Faker::Lorem.words(3).join(' '), stage_id: stage.id
    (rand(2)+1).times do
      image = widget.images.new
      image.skip_file_check!
      image.remote_file_url = 'http://lorempixel.com/640/480/technics'
    end
    widget.completion_share = rand 100
    widget.completion_rate = rand 100
    widget.save
  end
  rand(10).times do
    user = User.find_by_id(rand(100)+1)
    user.follow_project project if user
  end
end

Project.index.import Project.all
User.index.import User.all