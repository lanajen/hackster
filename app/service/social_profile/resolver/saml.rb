module SocialProfile::Resolver
  class Saml < Base
    def profile_attributes
      {
        full_name: info.first_name.to_s + ' ' + info.last_name.to_s,
        user_name: clean_user_name(data.extra.raw_info.attributes['username'].try(:first)),
        email: info.email,
        city: data.extra.raw_info.attributes['state'].try(:first),
        country: data.extra.raw_info.attributes['country'].try(:first),
      }
    end
  end
end