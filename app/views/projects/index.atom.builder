atom_feed language: 'en-US' do |feed|
  feed.title title
  feed.updated (params[:show_all] ? @projects.first.try(:made_public_at) : @projects.first.try(:featured_date))

  @projects.each do |project|
    feed.entry(project) do |entry|
      entry.title project.name
      entry.content project.one_liner
      entry.link href: project.decorate.cover_image(:cover_thumb), rel:"enclosure", type:"image/jpeg"

      project.users.each do |user|
        entry.author do |author|
          author.name user.name
          author.uri user_url(user)
        end
      end
    end
  end
end