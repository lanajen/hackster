APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]
SLOGAN = 'Hackster.io is the place where hardware hackers and makers showcase their projects.'
URL_REGEXP = /^(((http|https):\/\/|)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}(:[0-9]{1,5})?(\/.*)?)$/ix