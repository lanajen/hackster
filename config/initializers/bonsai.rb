BONSAI_INDEX_NAME = if ENV['BONSAI_INDEX_URL']
  Tire.configure do
    url "http://index.bonsai.io"
  end
  ENV['BONSAI_INDEX_URL'][/[^\/]+$/]
else
  app_name = Rails.application.class.parent_name.underscore.dasherize
  "#{app_name}-#{Rails.env}"
end