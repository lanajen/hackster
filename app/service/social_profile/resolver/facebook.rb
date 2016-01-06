module SocialProfile::Resolver
  class Facebook < Base
    def profile_attributes
      {
        user_name: clean_user_name(info.nickname),
        email: info.email,
        full_name: info.name,
        mini_resume: info.description,
        facebook_link: info.urls['Facebook'],
        website_link: info.urls['Website'],
        city: info['location'].try(:[], 'name').try(:split, ',').try(:[], 0),
        country: info['location'].try(:[], 'name').try(:split, ',').try(:[], 1).try(:strip),
        image_url: "https://graph.facebook.com/#{data.uid}/picture?height=200&width=200",
      }
    end
  end
end