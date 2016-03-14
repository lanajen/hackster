module SocialProfile::Resolver
  class Arduino < Base
    def profile_attributes
      {
        user_name: clean_user_name(data.uid),
        email: info.email,
        image_url: "https://dcw9y8se13llu.cloudfront.net/avatars/#{data.uid}.jpg",
        custom_image_url: "https://dcw9y8se13llu.cloudfront.net/avatars/#{data.uid}.jpg",
        skip_email_confirmation: true,
      }
    end
  end
end