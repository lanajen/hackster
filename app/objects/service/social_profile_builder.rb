require 'country_iso_translater'

class SocialProfileBuilder
  KNOWN_PROVIDERS = {
    'Facebook' => :facebook,
    'Twitter' => :twitter,
    'Google+' => :gplus,
    'LinkedIn' => :linked_in,
    'Github' => :github,
    'Microsoft' => :windowslive,
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
      send KNOWN_PROVIDERS[provider], info, data
    end
    # logger.info 'auth: ' + @user.authorizations.inspect
    generate_user_name if @user.class.where(user_name: @user.user_name).any?
    @user.password = Devise.friendly_token[0,20]
    @user.logging_in_socially = true
    @user
  end

  private
    def clean_user_name user_name
      user_name.try(:downcase).try(:gsub, /[^a-z0-9_\-]/, '')
    end

    def facebook info, data
      @user.user_name = clean_user_name(info.nickname) if @user.user_name.blank?
      @user.email = @user.email_confirmation = info.email if @user.email.blank?
      @user.full_name = info.name if @user.full_name.blank?
      @user.mini_resume = info.description if @user.mini_resume.blank?
      @user.facebook_link = info.urls['Facebook']
      @user.website_link = info.urls['Website']
      begin
        if location = info['location']# || extra['raw_info']['hometown']
          @user.city = location['name'].split(',')[0] if @user.city.nil?
          @user.country = location['name'].split(',')[1].strip if @user.country.nil?
        end

      rescue => e
        logger.error "Error in extract_from_social_profile (facebook location): " + e.inspect
      end
      begin
        image_url = "https://graph.facebook.com/#{data.uid}/picture?height=200&width=200"
        @user.build_avatar(remote_file_url: image_url) if image_url and not @user.avatar
      rescue => e
        logger.error "Error in extract_from_social_profile (facebook avatar): " + e.inspect
      end
      @user.authorizations.build(
        uid: data.uid,
        provider: 'Facebook',
        name: info.name.to_s,
        link: info.urls['Facebook'],
        token: data.credentials.token
      )
    end

    def github info, data
      @user.user_name = clean_user_name(info.nickname) if @user.user_name.blank?
      @user.full_name = info.name if @user.full_name.blank?
      @user.email = @user.email_confirmation = info.email if @user.email.blank?
      @user.github_link = info.urls['GitHub']
      @user.website_link = info.urls['Blog']
      begin
        @user.city = info.location.try(:split, ',').try(:[], 0) if @user.city.nil?
        @user.country = info.location.try(:split, ',').try(:[], 1).try(:strip) if @user.country.nil?
      rescue => e
        logger.error "Error in extract_from_social_profile (github): " + e.inspect
      end
      @user.authorizations.build(
        uid: data.uid,
        provider: 'Github',
        name: info.name.to_s,
        link: info.urls['GitHub'],
        token: data.credentials.token
      )
    end

    def gplus info, data
      @user.user_name = clean_user_name(info.email.match(/^([^@]+)@/)[1]) if @user.user_name.blank?
      @user.full_name = info.name if @user.full_name.blank?
      @user.email = @user.email_confirmation = info.email if @user.email.blank?
      @user.google_plus_link = info.urls['Google+']
      begin
        # @user.city = info.location.split(',')[0] if city.nil?
        # @user.country = info.location.split(',')[1].strip if country.nil?
        @user.build_avatar(remote_file_url: info.image) if info.image and not @user.avatar
      rescue => e
        logger.error "Error in extract_from_social_profile (google+): " + e.inspect
      end
      @user.authorizations.build(
        uid: data.uid,
        provider: 'Google+',
        name: info.name.to_s,
        link: info.urls['Google+'],
        token: data.credentials.token
      )
    end

    def linked_in info, data
      # @user.user_name = clean_user_name(info.nickname) if user_name.blank?
      @user.full_name = info.first_name.to_s + ' ' + info.last_name.to_s if @user.full_name.blank?
      @user.email = @user.email_confirmation = info.email if @user.email.blank?
      @user.mini_resume = info.description if @user.mini_resume.nil?
      @user.linked_in_link = info.urls['public_profile']
      begin
        @user.city = info.location.name if @user.city.nil?
        @user.country =
          SunDawg::CountryIsoTranslater.translate_iso3166_alpha2_to_name(
            info.location.country.code.upcase) if @user.country.nil?
        @user.build_avatar(remote_file_url: info.image) if info.image and not @user.avatar
      rescue => e
        logger.error "Error in extract_from_social_profile (linkedin): " + e.inspect
      end
      @user.authorizations.build(
        uid: info.uid,
        provider: 'LinkedIn',
        name: info.first_name.to_s + ' ' + info.last_name.to_s,
        link: info.urls['public_profile'],
        token: data.credentials.token
      )
    end

    def twitter info, data
      @user.user_name = clean_user_name(info.nickname) if @user.user_name.blank?
      @user.full_name = info.name if @user.full_name.blank?
      @user.mini_resume = info.description if @user.mini_resume.nil?
      @user.interest_tags_string = info.description.scan(/\#([[:alpha:]]+)/i).join(',')
      @user.twitter_link = info.urls['Twitter']
      begin
        @user.city = info.location.split(',')[0] if @user.city.nil?
        @user.country = info.location.split(',')[1].strip if @user.country.nil?
        @user.build_avatar(remote_file_url: info.image.gsub(/_normal/, '')) unless @user.avatar
      rescue => e
        logger.error "Error in extract_from_social_profile (twitter): " + e.inspect
      end
      @user.authorizations.build(
        uid: data.uid,
        provider: 'Twitter',
        name: info.name,
        link: info.urls['Twitter'],
        token: data.credentials.token,
        secret: data.credentials.secret
      )
    end

    def windowslive info, data
      @user.full_name = info.name if @user.full_name.blank?
      @user.email = @user.email_confirmation = info.emails.try(:first).try(:value) if @user.email.blank?
      @user.authorizations.build(
        uid: data.uid,
        provider: 'Microsoft',
        name: info.name,
        token: data.credentials.token
      )
    end
end