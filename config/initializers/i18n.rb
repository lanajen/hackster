require "i18n/backend/fallbacks"
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
I18n::Locale::Tag.implementation = I18n::Locale::Tag::Simple

I18n.module_eval do
  extend(Module.new {
    attr_accessor :active_locales, :short_locale, :default_www_locale
  })
end
I18n.active_locales = [:en]
I18n.default_www_locale = nil