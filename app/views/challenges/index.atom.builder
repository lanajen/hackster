atom_feed language: 'en-US' do |feed|
  feed.title 'Active hardware contests'
  feed.updated @active_challenges.first.try(:updated_at)

  @active_challenges.each do |challenge|
    feed.entry(challenge) do |entry|
      entry.title challenge.name
      entry.content challenge.teaser if challenge.teaser.present?
      entry.link href: challenge.decorate.cover_image(:cover_wide_small), rel: "enclosure", type:"image/jpeg"

      challenge.sponsors.each do |sponsor|
        entry.author do |author|
          author.name sponsor.name
          author.uri group_url(sponsor)
        end
      end
    end
  end
end