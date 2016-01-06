module SocialProfile::Resolver
  class Arduino < Base
    def profile_attributes
      {
        user_name: clean_user_name(info.id),
        email: info.email,
        image_url: "https://dcw9y8se13llu.cloudfront.net/avatars/#{data.uid}.jpg",
      }
    end
  end
end