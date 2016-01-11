require 'country_iso_translater'
require 'hashie/mash'

module SocialProfile
  class Builder
    KNOWN_PROVIDERS = {
      'arduino' => :arduino,
      'facebook' => :facebook,
      'github' => :github,
      'gplus' => :google_plus,
      'linkedin' => :linked_in,
      'saml' => :saml,
      'twitter' => :twitter,
      'windowslive' => :windowslive,
    }

    def initialize provider, data
      @provider = provider
      @data = data
      raise UnknownProvider, "`#{provider}` isn't recognized" unless provider
      @resolver = "SocialProfile::Resolver::#{provider.camelize}".constantize.new(data)
    end

    def initialize_user_from_social_profile user
      @user = user
      # Rails.logger.debug 'user: ' + @user.to_yaml

      assign_attributes social_profile_attributes.except(:image_url, :custom_image_url)
      image_url = social_profile_attributes[:image_url]
      build_avatar image_url if image_url

      custom_image_url = social_profile_attributes[:custom_image_url]
      assign_custom_image_url custom_image_url, @provider if custom_image_url

      @user.email_confirmation = @user.email
      @user.authorizations.build(
        uid: @data.uid,
        provider: @provider,
        name: @user.full_name,
        link: provider_link(@provider),
        token: @data.credentials.token,
        secret: @data.credentials.secret
      )

      # logger.info 'auth: ' + @user.authorizations.inspect
      @user.generate_user_name unless UserNameValidator.new(@user).valid?
      @user.password = Devise.friendly_token[0,20]
      @user.logging_in_socially = true
      @user
    end

    def social_profile_attributes
      @social_profile_attributes ||= Hashie::Mash.new(@resolver.profile_attributes)
    end

    class UnknownProvider < StandardError; end

    private
      def assign_attributes attributes
        attributes.each do |name, value|
          @user.send("#{name}=", value) if @user.send(name).blank?
        end
      end

      def assign_custom_image_url image_url, provider
        CustomAvatarHandler.new(@user).add(provider, image_url)
      end

      def build_avatar image_url
        if image_url and not @user.avatar
          @user.build_avatar(remote_file_url: image_url)
          @user.avatar.delete unless @user.avatar.file.url
        end
      rescue => e
        logger.error "Error in extract_from_social_profile (avatar): " + e.inspect
      end

      def provider_link provider
        attr_name = "#{KNOWN_PROVIDERS[provider]}_link"
        @user.send attr_name if @user.respond_to? attr_name
      end
  end

  module Resolver
    class Base
      attr_reader :data, :info

      def initialize data
        @data = data
        @info = data.info
        Rails.logger.debug 'data: ' + data.to_yaml
      end

      def profile_attributes
        {}
      end

      private
        def clean_user_name user_name
          user_name.try(:gsub, /[^a-zA-Z0-9_\-]/, '')
        end
    end
  end
end