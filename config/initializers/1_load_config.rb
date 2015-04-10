APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]
PDT_TIME_ZONE = ActiveSupport::TimeZone.new('Pacific Time (US & Canada)')
POPULAR_TAGS = {
  'Arduino' => '/arduino',
  'ATtiny' => '/tags/attiny',
  'AVR' => '/avr',
  'BeagleBoard' => '/beagleboard',
  'Bluetooth' => '/tags/bluetooth',
  # 'Drone' => '/tags/drone',
  'Home automation' => '/tags/home+automation',
  'MetaWear' => '/metawear',
  'MSP430' => '/tags/msp430',
  'Raspberry Pi' => '/raspberry-pi',
  'Sensors' => '/tags/sensor',
  'Spark' => '/spark',
  'Teensy' => '/teensy',
  'Wifi' => '/tags/wifi',
  'Wearable' => '/tags/wearable',
}

SLOGAN = 'Hackster is the place where hardware gets created. Learn, share and connect to build better hardware.'
SLOGAN_NO_BRAND = 'The place where hardware gets created.'
# where hardware comes to life
URL_REGEXP = /^(((http|https):\/\/|)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}(:[0-9]{1,5})?(\/.*)?)$/ix
EMAIL_REGEXP = /^[a-zA-Z0-9_\.\+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-\.]+$/

if Rails.env == 'development'
  ENV['FOG_DIRECTORY'] = ENV['DEV_FOG_DIRECTORY'] if ENV['UPLOAD'] == 'dev'
  puts "Using #{ENV['FOG_DIRECTORY']} for FOG_DIRECTORY"
  ENV['CARRIERWAVE_FORCE_FOG'] = ENV['UPLOAD'].in?(%w(dev prod)).to_s
  puts ENV['CARRIERWAVE_FORCE_FOG'] == 'true' ? "Forcing use of fog" : 'Using default storage'
end


IMAGE_EXTENSIONS = %w(jpg jpeg gif bmp png)
PDF_EXTENSIONS = %w(pdf)

SKETCHFAB_API_URL = 'https://api.sketchfab.com/v2'
SKETCHFAB_API_MODEL_ENDPOINT = SKETCHFAB_API_URL + '/models'
SKETCHFAB_API_TOKEN = 'f6f4db3865a945a38f0d09cae381efd6'
SKETCHFAB_SUPPORTED_EXTENSIONS = %w(3dc 3ds ac asc bvh blend geo dae dwf dw x fbx gta mu kmz lwo lws flt iv osg osgt osgb ive ply shp stl vpk wrl ojb)