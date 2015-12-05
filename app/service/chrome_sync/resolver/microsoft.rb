module ChromeSync::Resolver
  class Microsoft < Base
    def getter attribute, locale
      replace_urls super
    end

    private
      def cache_key attribute, locale
        locale ||= default_locale
        locale = locale.try(:[], 0..1)
        super attribute, locale
      end

      def format_locale locale
        locale = locale.try(:[], 0..1)
        super locale
      end

      def ms_config
        @ms_config ||= YAML.load_file(File.join(Rails.root, 'config/microsoft.yml'))[Rails.env]
      end

      def replace_urls text
        return unless text

        text.scan(/\{\{([a-z_\.]+)\}\}/).each do |token|
          token = token.first if token.class == Array
          sub = ms_config[token]
          text = text.gsub("{{#{token}}}", sub) if sub
        end
        text
      end
  end
end