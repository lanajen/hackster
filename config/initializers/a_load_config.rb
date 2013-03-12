APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]
S3 = YAML.load_file("#{Rails.root}/config/server/s3.yml")