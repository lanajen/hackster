module SocialProfile::Resolver
  class Gplus < Base
    def profile_attributes
      {
        user_name: clean_user_name(info.email.match(/^([^@]+)@/)[1]),
        full_name: info.name,
        email: info.email,
        google_plus_link: info.urls['Google+'],
        image_url: info.image,
      }
    end
  end
end