APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]
SLOGAN = 'Hackster.io gives professionals and hobbyists the resources they need to build hardware the easy way.'
URL_REGEXP = /^(((http|https):\/\/|)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}(:[0-9]{1,5})?(\/.*)?)$/ix