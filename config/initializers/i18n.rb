require "i18n/backend/fallbacks"
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
I18n::Locale::Tag.implementation = I18n::Locale::Tag::Simple