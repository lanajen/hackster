module SocialProfile::Resolver
  class Facebook < Base
    def profile_attributes
      {
        user_name: clean_user_name(info.nickname),
        email: info.email,
        full_name: info.name,
        mini_resume: info.description,
        facebook_link: info.urls.try(:[], 'Facebook'),
        website_link: info.urls.try(:[], 'Website'),
        city: info.location.try(:split, ',').try(:[], 0),
        country: info.location.try(:split, ',').try(:[], 1).try(:strip),
        image_url: info.image,
      }
    end
  end
end