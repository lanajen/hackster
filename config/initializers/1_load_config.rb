APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]
SLOGAN = 'Hackster.io is a collaborative knowledge base for the hardware maker community.'
URL_REGEXP = /^(((http|https):\/\/|)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}(:[0-9]{1,5})?(\/.*)?)$/ix