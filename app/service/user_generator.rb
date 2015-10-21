class UserGenerator
  def self.generate_user
    full_name = nil
    while full_name.nil? or full_name =~ /\p{Han}/
      gender = %w(male male male male male male male male male female).sample  # 90% male
      country = rand(1..10) > 6 ? "&country=united+states" : ''
      resp = JSON.parse Net::HTTP.get_response("api.uinames.com","/?gender=#{gender}#{country}").body
      generator = NameGenerator.new(resp['name'], resp['surname'])
      if generator.last_name.present?
        full_name = generator.full_name
        user_name = generator.user_name
      end
    end

    u = nil
    while u.nil? or !u.persisted?
      email = SecureRandom.hex(5) + '@user.hackster.io'
      user_data = {
        email: email,
        email_confirmation: email,
        password: SecureRandom.hex(16),
        full_name: full_name,
        user_name: user_name,
      }
      u = User.new
      u.skip_confirmation!
      u.assign_attributes user_data
      u.save
      u.unsubscribe_from_all
      u.save
    end
    groups = []
    Platform.public.featured.each do |plat|
      (Math.log(plat.followers_count) * Math.log(plat.followers_count)).to_i.times{ groups << plat.id } unless plat.followers_count.zero?
    end
    rand(1..5).times do
      FollowRelation.add u, Group.find(groups.sample), true
    end
    project_ids = BaseArticle.indexable.last_30days.pluck(:id) + BaseArticle.magic_sort.limit(50).pluck(:id)
    rand(1..10).times do
      project = BaseArticle.find project_ids.sample
      project.impressions.create user_id: u.id, controller_name: 'projects', action_name: 'show', message: 'tmp', request_hash: SecureRandom.hex(16)
      if [true, false, false, false, false, false, false, false, false, false].sample  # prob = 0.1
        Respect.create_for u, project
      end
    end
  end
end