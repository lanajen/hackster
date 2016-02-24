module SocialProfile::Resolver
  class Twitter < Base
    def profile_attributes
      {
        user_name: clean_user_name(info.nickname),
        full_name: info.name,
        mini_resume: info.description,
        interest_tags_string: info.description.scan(/\#([[:alpha:]]+)/i).join(','),
        twitter_link: info.urls['Twitter'],
        city: info.location.try(:split, ',').try(:[], 0),
        country: info.location.try(:split, ',').try(:[], 1).try(:strip),
        image_url: info.image.gsub(/_normal/, ''),
      }
    end
  end
end