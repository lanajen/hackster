atom_feed language: 'en-US' do |feed|
  feed.title 'Active hardware contests'
  feed.updated @active_challenges.first.try(:updated_at)

  @active_challenges.each do |challenge|
    feed.entry(challenge) do |entry|
      entry.url challenge_url(challenge)
      entry.title challenge.name
      entry.content challenge.teaser if challenge.teaser.present?
      entry.link href: challenge.decorate.cover_image(:cover_wide_small), rel: "enclosure", type:"image/jpeg"

      # the strftime is needed to work with Google Reader.
      entry.updated(challenge.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ"))
      entry.published(challenge.dates.first[:date].strftime("%Y-%m-%dT%H:%M:%SZ"))

      challenge.sponsors.each do |sponsor|
        entry.author do |author|
          author.name sponsor.name
          author.url group_url(sponsor)
        end
      end
    end
  end
end