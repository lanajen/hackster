ALGOLIA_INDEX_PREFIX = "hackster_#{ENV['ALGOLIA_ENV'] || Rails.env}"

Algolia.init :application_id => ENV['ALGOLIA_APP_ID'],
             :api_key        => ENV['ALGOLIA_API_KEY']