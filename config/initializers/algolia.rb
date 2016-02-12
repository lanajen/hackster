ALGOLIA_INDEX_NAME = "hackster_#{Rails.env}"

Algolia.init :application_id => ENV['ALGOLIA_APP_ID'],
             :api_key        => ENV['ALGOLIA_API_KEY']