module SocialProfile::Resolver
  class Windowslive < Base
    def profile_attributes
      {
        full_name: info.name,
        email: info.emails.try(:first).try(:value),
      }
    end
  end
end