module SocialProfile::Resolver
  class Linkedin < Base
    def profile_attributes
      {
        full_name: info.first_name.to_s + ' ' + info.last_name.to_s,
        email: info.email,
        mini_resume: info.description,
        linked_in_link: info.urls['public_profile'],
        city: info.location.try(:name),
        country: SunDawg::CountryIsoTranslater.translate_iso3166_alpha2_to_name(
                info.location.try(:country).try(:code).try(:upcase)),
        image_url: info.image,
      }
    end
  end
end