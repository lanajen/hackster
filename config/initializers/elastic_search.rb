# https://n2q4fgoc:6oq44a1mum8w8fb9@971411a61cbc894c000.qbox.io/hacker-io-production
ENV['ELASTICSEARCH_URL'] ||= ENV['BONSAI_URL']

app_name = Rails.application.class.parent_name.underscore.dasherize
ELASTIC_SEARCH_INDEX_NAME = "#{app_name}-#{Rails.env}"