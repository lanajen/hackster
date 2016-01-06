module SocialProfile::Resolver
  class Github < Base
    def profile_attributes
      {
        user_name: clean_user_name(info.nickname),
        full_name: info.name,
        email: info.email,
        github_link: info.urls['Github'],
        website_link: info.urls['Blog'],
        city: info.location.try(:split, ',').try(:[], 0),
        country: info.location.try(:split, ',').try(:[], 1).try(:strip),
        image_url: info.image,
      }
    end
  end
end