require 'country_iso_translater'

class SocialProfileBuilder
  KNOWN_PROVIDERS = {
    'facebook' => :facebook,
    'twitter' => :twitter,
    'gplus' => :google_plus,
    'linkedin' => :linked_in,
    'github' => :github,
    'windowslive' => :windowslive,
  }

  def initialize user
    @user = user
  end

  def extract_from_social_profile params, session
    data = session['devise.provider_data']
    extra = data.extra
    info = data.info
    provider = session['devise.provider']
    # logger.info data.to_yaml
    # logger.info provider.to_s
    # logger.info 'user: ' + @user.to_yaml
    if info and provider.in? KNOWN_PROVIDERS.keys
      send provider, info, data
      @user.email_confirmation = @user.email
      @user.authorizations.build(
        uid: data.uid,
        provider: provider,
        name: @user.full_name,
        link: provider_link(provider),
        token: data.credentials.token,
        secret: data.credentials.secret
      )
    end
    # logger.info 'auth: ' + @user.authorizations.inspect
    @user.generate_user_name if SlugHistory.where(value: @user.user_name).any?
    @user.password = Devise.friendly_token[0,20]
    @user.logging_in_socially = true
    @user
  end

  private
    def assign_attributes attributes
      attributes.each do |name, value|
        @user.send("#{name}=", value) if @user.send(name).blank?
      end
    end

    def build_avatar image_url
      if image_url and not @user.avatar
        @user.build_avatar(remote_file_url: image_url)
        @user.avatar.delete unless @user.avatar.file.url
      end
    rescue => e
      logger.error "Error in extract_from_social_profile (avatar): " + e.inspect
    end

    def clean_user_name user_name
      user_name.try(:downcase).try(:gsub, /[^a-z0-9_\-]/, '')
    end

    def provider_link provider
      attr_name = "#{KNOWN_PROVIDERS[provider]}_link"
      @user.send attr_name if @user.respond_to? attr_name
    end

    def facebook info, data
      assign_attributes(
        user_name: clean_user_name(info.nickname),
        email: info.email,
        full_name: info.name,
        mini_resume: info.description,
        facebook_link: info.urls['Facebook'],
        website_link: info.urls['Website'],
        city: info['location'].try(:[], 'name').try(:split, ',').try(:[], 0),
        country: info['location'].try(:[], 'name').try(:split, ',').try(:[], 1).try(:strip)
      )
      image_url = "https://graph.facebook.com/#{data.uid}/picture?height=200&width=200"
      build_avatar image_url
    end

    def github info, data
      assign_attributes(
        user_name: clean_user_name(info.nickname),
        full_name: info.name,
        email: info.email,
        github_link: info.urls['Github'],
        website_link: info.urls['Blog'],
        city: info.location.try(:split, ',').try(:[], 0),
        country: info.location.try(:split, ',').try(:[], 1).try(:strip)
      )
    end

    def gplus info, data
      assign_attributes(
        user_name: clean_user_name(info.email.match(/^([^@]+)@/)[1]),
        full_name: info.name,
        email: info.email,
        google_plus_link: info.urls['Google+']
      )
      build_avatar info.image
    end

    def linkedin info, data
      assign_attributes(
        full_name: info.first_name.to_s + ' ' + info.last_name.to_s,
        email: info.email,
        mini_resume: info.description,
        linked_in_link: info.urls['public_profile'],
        city: info.location.try(:name),
        country: SunDawg::CountryIsoTranslater.translate_iso3166_alpha2_to_name(
            info.location.try(:country).try(:code).try(:upcase))
      )
      build_avatar info.image
    end

    def twitter info, data
      assign_attributes(
        user_name: clean_user_name(info.nickname),
        full_name: info.name,
        mini_resume: info.description,
        interest_tags_string: info.description.scan(/\#([[:alpha:]]+)/i).join(','),
        twitter_link: info.urls['Twitter'],
        city: info.location.try(:split, ',').try(:[], 0),
        country: info.location.try(:split, ',').try(:[], 1).try(:strip)
      )
      build_avatar info.image.gsub(/_normal/, '')
    end

    def windowslive info, data
      assign_attributes(
        full_name: info.name,
        email: info.emails.try(:first).try(:value)
      )
    end
end